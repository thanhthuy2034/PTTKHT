package controller;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter(urlPatterns = "/*", dispatcherTypes = { DispatcherType.REQUEST, DispatcherType.FORWARD })
public class RequestFilter9 implements Filter {
    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        if (path.startsWith("/assets/")) {
            chain.doFilter(req, res);
            return;
        }
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("X-Content-Type-Options", "nosniff");
        response.setHeader("X-Frame-Options", "DENY");
        response.setHeader("Content-Security-Policy",
                "default-src 'self'; img-src 'self'; style-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'self'");
        if (path.startsWith("/WEB-INF/") && request.getDispatcherType() == DispatcherType.REQUEST) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        chain.doFilter(req, res);
    }
}
