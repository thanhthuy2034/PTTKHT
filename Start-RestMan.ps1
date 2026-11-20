param(
    [string]$TomcatHome = $env:CATALINA_HOME,
    [string]$JavaHome = $env:JAVA_HOME
)

$ErrorActionPreference = 'Stop'
if (!$TomcatHome -or !$JavaHome) { throw 'Set CATALINA_HOME and JAVA_HOME, or pass -TomcatHome and -JavaHome.' }
$TomcatHome = (Resolve-Path -LiteralPath $TomcatHome).Path
$JavaHome = (Resolve-Path -LiteralPath $JavaHome).Path
$runtime = Join-Path $PSScriptRoot '.tomcat'
$war = Join-Path $PSScriptRoot 'target\restman.war'
foreach ($file in @("$TomcatHome\bin\catalina.bat", "$TomcatHome\lib\catalina.jar", "$JavaHome\bin\java.exe", "$JavaHome\bin\javac.exe", "$JavaHome\release", $war)) {
    if (!(Test-Path -LiteralPath $file)) { throw "Missing: $file" }
}
if (-not (Select-String -LiteralPath "$JavaHome\release" -Pattern '^JAVA_VERSION="17(?:\.|\")' -Quiet)) {
    throw 'RestMan requires JDK 17. Check JAVA_HOME or -JavaHome.'
}
$serverInfo = & "$JavaHome\bin\java.exe" -cp "$TomcatHome\lib\catalina.jar" org.apache.catalina.util.ServerInfo
if ($LASTEXITCODE -ne 0 -or -not ($serverInfo -match 'Apache Tomcat/9\.')) {
    throw 'RestMan requires Tomcat 9. Check CATALINA_HOME or -TomcatHome.'
}

# Prefer an explicit configuration; otherwise use an ignored local file outside the WAR.
$dbConfig = $env:RESTMAN_DB_CONFIG
if (!$dbConfig) {
    foreach ($candidate in @("$PSScriptRoot\restman-db.local.properties", "$runtime\conf\restman-db.local.properties")) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { $dbConfig = $candidate; break }
    }
}
if ($dbConfig) { $dbConfig = (Resolve-Path -LiteralPath $dbConfig).Path }

# Leave existing servers alone, including any instance started by NetBeans.
$probe = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 8080)
try { $probe.Start() } catch { throw 'Port 8080 is busy. No process was stopped.' } finally { $probe.Stop() }

foreach ($folder in 'conf', 'logs', 'temp', 'webapps', 'work', 'bin') {
    New-Item -ItemType Directory -Path (Join-Path $runtime $folder) -Force | Out-Null
}
foreach ($file in 'catalina.properties', 'context.xml', 'logging.properties', 'web.xml') {
    Copy-Item -LiteralPath "$TomcatHome\conf\$file" -Destination "$runtime\conf\$file"
}
$config = @'
<?xml version="1.0" encoding="UTF-8"?>
<Server port="-1">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
  <Service name="Catalina">
    <Connector address="127.0.0.1" port="8080" protocol="HTTP/1.1" connectionTimeout="20000" URIEncoding="UTF-8" />
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" prefix="localhost_access_log" suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
      </Host>
    </Engine>
  </Service>
</Server>
'@
[IO.File]::WriteAllText("$runtime\conf\server.xml", $config, [Text.UTF8Encoding]::new($false))
Copy-Item -LiteralPath $war -Destination "$runtime\webapps\restman.war"

$values = @{JAVA_HOME=$JavaHome; JRE_HOME=$JavaHome; CATALINA_HOME=$TomcatHome; CATALINA_BASE=$runtime; CATALINA_TMPDIR="$runtime\temp"}
if ($dbConfig) { $values['RESTMAN_DB_CONFIG'] = $dbConfig }
$previous = @{}
try {
    foreach ($name in $values.Keys) {
        $previous[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
        [Environment]::SetEnvironmentVariable($name, $values[$name], 'Process')
    }
    Write-Host 'RestMan: http://localhost:8080/restman/ (Ctrl+C to stop)'
    & "$TomcatHome\bin\catalina.bat" run
    if ($LASTEXITCODE -ne 0) { throw "Tomcat exited with code $LASTEXITCODE" }
} finally {
    foreach ($name in $previous.Keys) {
        [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
    }
}
