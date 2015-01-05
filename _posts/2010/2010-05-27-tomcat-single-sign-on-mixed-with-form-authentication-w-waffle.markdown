---
layout: post
title: "Tomcat Single Sign-On mixed with Form Authentication w/ Waffle"
redirect_from: "/tomcat-single-sign-on-mixed-with-form-authentication-w-waffle"
date: 2010-05-27 13:01:40
tags: [waffle, jna, security, java, active directory]
comments: true
---
![waffle]({{ site.url }}/images/posts/2010/2010-05-27-tomcat-single-sign-on-mixed-with-form-authentication-w-waffle/waffle%5b3%5d.jpg)

Most Tomcat users begin by implement Form-based authentication. Those deploying applications into enterprises soon discover that those enterprises use an Active Directory and have single sign-on on all intranet sites. They eventually find [Waffle](https://github.com/dblock/waffle/), but don’t want to take the ability to do form-based logon away.

_How do we give users a way to logon either way?_

![image]({{ site.url }}/images/posts/2010/2010-05-27-tomcat-single-sign-on-mixed-with-form-authentication-w-waffle/image2.jpg)

You can accomplish this with the Waffle _MixedAuthenticator_.

#### Configure Tomcat

_Download and Copy Files_

Download [Waffle 1.3](https://github.com/dblock/waffle/) and copy _waffle-jna.jar_, _jna.jar_ and _platform.jar_ to Tomcat's lib directory.

_Configure Mixed Authenticator Valve_

Add a valve and a realm to the application context. For an application, modify _META-INF\context.xml_.

```xml
<?xml version='1.0' encoding='utf-8'?>
<Context>
  <Valve className="waffle.apache.MixedAuthenticator" principalFormat="fqn" roleFormat="both" />
  <Realm className="waffle.apache.WindowsRealm" />
</Context>
```

_Security Roles and Constraints_

Configure security roles in _WEB-INF\web.xml_. The Waffle Mixed Authenticator adds all user's security groups (including nested and domain groups) as roles during authentication.

```xml
<security-role>
  <role-name>Everyone</role-name>
</security-role>
```

Restrict access to website resources.

```xml
<security-constraint>
  <display-name>Waffle Security Constraint</display-name>
  <web-resource-collection>
    <web-resource-name>Protected Area</web-resource-name>
    <url-pattern>/*</url-pattern>
  </web-resource-collection>
  <auth-constraint>
    <role-name>Everyone</role-name>
  </auth-constraint>
</security-constraint>
```

Add a second security constraint that leaves the login page unprotected.

```xml
<security-constraint>
  <display-name>Login Page</display-name>
  <web-resource-collection>
    <web-resource-name>Unprotected Login Page</web-resource-name>
    <url-pattern>/login.jsp</url-pattern>
  </web-resource-collection>
</security-constraint>
```

_Configure Form Login_

Configure Form Login parameters with the location of the login page (repeated from the security constraint above) and an error page for failed logins. Modify _WEB-INF\web.xml_.

```xml
<login-config>
   <form-login-config>
      <form-login-page>/login.jsp</form-login-page>
      <form-error-page>/error.html</form-error-page>
   </form-login-config>
</login-config>
```

_Login Page_

Create a login page based on the following code. There're two requirements for the login form. The form-based authentication must post to any valid location with the _j_security_check_ parameter. The destination page will be loaded after a successful login. The single sign-on form must similarly post to any valid location with the _j_negotiate_check_ parameter in the query string.

Here’s a rudimentary example that lands an authenticated user on _index.jsp_.

```html
<form method="POST" name="loginform" action="index.jsp?j_security_check">
    <table style="vertical-align: middle;">
        <tr>
            <td>Username:</td>
            <td><input type="text" name="j_username" /></td>
        </tr>
        <tr>
            <td>Password:</td>
            <td><input type="password" name="j_password" /></td>
        </tr>
        <tr>
            <td><input type="submit" value="Login" /></td>
        </tr>
    </table>
    </form>
    <hr>
    <form method="POST" name="loginform" action="index.jsp?j_negotiate_check">
    <input type="submit" value="Login w/ Current Windows Credentials" />
</form>
```

#### Demo

A demo application can be found in the Waffle distribution in the _Samples\Tomcat\waffle-mixed_ directory. Copy the entire directory into Tomcat's _webapps_ directory and navigate to http://localhost:8080/waffle-mixed. Pick your method of login.

#### How does it Work?

Implementation details follow. Read at your own risk.

From the unauthenticated login page we are making two possible requests: one will trigger Single Sign-On and another will trigger form-based authentication. To do single sign-on we will need access to the request/response objects and to do forms authentication we will need access to the realms interface. The place where we have both is in `org.apache.catalina.Authenticator`.

```java
@Override
protected boolean authenticate(Request request, Response response, LoginConfig loginConfig) {

    String queryString = request.getQueryString();
    boolean negotiateCheck = (queryString != null && queryString.equals("j_negotiate_check"));
    boolean securityCheck = (queryString != null && queryString.equals("j_security_check"));

    Principal principal = request.getUserPrincipal();

    AuthorizationHeader authorizationHeader = new AuthorizationHeader(request);
    boolean ntlmPost = authorizationHeader.isNtlmType1PostAuthorizationHeader();

    if (principal != null && ! ntlmPost) {
        return true;
    } else if (negotiateCheck) {
        if (! authorizationHeader.isNull()) {
            return negotiate(request, response, authorizationHeader);
        } else {
            sendUnauthorized(response);
            return false;
        }
    } else if (securityCheck) {
        boolean postResult = post(request, response, loginConfig);
        if (postResult) {
            redirectTo(request, response, request.getServletPath());
        } else {
            redirectTo(request, response, loginConfig.getErrorPage());
        }
        return postResult;
    } else {
        redirectTo(request, response, loginConfig.getLoginPage());
        return false;
    }
}
```

Negotiate mimics the behavior of `NegotiateAuthenticator`, while form post follows the standard Authenticator registration process.

```java
private boolean post(Request request, Response response, LoginConfig loginConfig) {
    String username = request.getParameter("j_username");
    String password = request.getParameter("j_password");
    IWindowsIdentity windowsIdentity = null;
    try {
        windowsIdentity = _auth.logonUser(username, password);
    } catch (Exception e) {
        return false;
    }

    WindowsPrincipal windowsPrincipal = new WindowsPrincipal(windowsIdentity, context.getRealm(), _principalFormat, _roleFormat);
    register(request, response, windowsPrincipal, "FORM", windowsPrincipal.getName(), null);
    return true;
}
```
