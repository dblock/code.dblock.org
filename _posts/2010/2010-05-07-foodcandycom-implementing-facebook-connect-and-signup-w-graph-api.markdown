---
layout: post
title: "FoodCandy.com: Implementing Facebook Connect and Signup w/ Graph API"
redirect_from: "/foodcandycom-implementing-facebook-connect-and-signup-w-graph-api/"
date: 2010-05-07 14:44:54
tags: [sncore, facebook, foodcandy, dotnet, asp.net]
comments: true
dblog_post_id: 99
---

![facebook]({{ site.url }}/images/posts/2010/2010-05-07-foodcandycom-implementing-facebook-connect-and-signup-w-graph-api/facebook_35.jpg)

#### Overview

I finally found some time to implement Facebook Connect for foodCandy.com. You can now do the following.

- Sign-Up with a Facebook account, no questions asked on FoodCandy.com.
- Associate an existing Facebook account with a previously created FoodCandy.com account.
- Login to FoodCandy with a previously associated Facebook account.

#### Is it hard?

It’s not. There’s about a day of work for all the items above, including this post.

#### Why am I writing this?

Two reasons.

There’re several interesting aspects to the FoodCandy service model, in particular that the website is just a front-end UI to SnCore and cannot do authentication. It needs to pass all data to the services back-end via a SOAP API, which in turn will do authentication. This means that we need to do more work and less magic.

I had to do some wrestling with JavaScript and the Facebook API at login. Most of the examples I found didn’t quite work. This post should, hopefully, be more helpful to those implementing Facebook Connect in C# / ASP.NET.

#### Application Registration

I registered [an application](https://www.facebook.com/#!/developers/apps.php), which gave me an API key and a shared secret. The first is public, but the latter is going to be stored on the back-end and used to verify login signatures or make authenticated calls to Facebook. You would typically store both in some configuration file, SnCore has a settings framework that lets you store both public information and "password"-like settings accessible to the back-end only.

![]({{ site.url }}/images/posts/2010/2010-05-07-foodcandycom-implementing-facebook-connect-and-signup-w-graph-api/image_3.jpg)

#### Single Sign On

The best document to read first is [here](https://developers.facebook.com/docs/guides/web).

_A Facebook Login Button_

I want a login button that gives users a choice of logging into the site with a username and a password, an OpenId and now with a Facebook login. The recommended way is to include some JavaScript and use FBML (a simple markup language) to render it. That approach caused me to have a click-popup-reload cycle, which I didn’t like at all. An alternate suggested way is to generate a login URL manually and let the user navigate away from the site, login to Facebook and return. This is simpler, IMHO, code non-withstanding.

{% highlight c# %}
public string GetLoginUrl(string returnUrl)
{
    return string.Format("https://www.facebook.com/login.php?api_key={0}&extern=1&fbconnect=1&req_perms=publish_stream,email&return_session=1&v=1.0&next={1}&fb_connect=1&cancel_url={1}",
        FacebookAPIKey, Renderer.UrlEncode(string.Format("{0}/FacebookConnect.aspx?connect=1&ReturnUrl={1}", mSessionManager.WebsiteUrl, Renderer.UrlEncode(returnUrl))));
}
{% endhighlight %}

The URL specifies the following.

- Tell Facebook login to return to FacebookConnect.aspx with parameters that will indicate the redirect location after a successful login. Facebook application settings require you to specify a single login return location. In addition this must be a dynamic page with a ? in the URL.
- Tell Facebook that we want _publish_stream_ and _email_ access. The _publish_stream_ option asks the user to authorize our application to publish content on Facebook, which is beyond the scope of this post. The _email_ option asks the user to authorize our application to send the user an e-mail. You don’t actually ever get the user’s e-mail, but an application-specific e-mail forward address.

_Redirect After Login_

A logged-in user is now returned to FacebookConnect.aspx with a number of parameters in the URL that contain session information.

Facebook JavaScript can process all that into cookies. The cookie names start with the API key. You can find a lot more detail about cookies [here](https://web.archive.org/web/20091223093524/https://wiki.developers.facebook.com/index.php/Verifying_The_Signature#Signatures_and_Facebook_Connect_Sites).

![]({{ site.url }}/images/posts/2010/2010-05-07-foodcandycom-implementing-facebook-connect-and-signup-w-graph-api/image_9.jpg)

Invoking this JavaScript gave me a lot of headache – I was properly redirected to FacebookConnect.aspx, but no cookies were set. The problem was that you need to initialize the Facebook API, then synchronously wait for it to set the cookies and therefore complete.

The following code works every time.

{% highlight html %}
<div id="fb-root"></div>
<script src="https://static.ak.connect.facebook.com/js/api_lib/v0.4/FeatureLoader.js.php" type="text/javascript"></script>
<script type="text/javascript">
  var facebookAPIKey = "<% Response.Write(FacebookAPIKey); %>";
  FB.init(facebookAPIKey);
  FB.ensureInit(function() {
   FB.Connect.get_status().waitUntilReady( function( status ) {
      switch ( status ) {
      case FB.ConnectState.connected:
         window.location="<% Response.Write(ReturnUrl); %>";
         break;
      case FB.ConnectState.appNotAuthorized:
      case FB.ConnectState.userNotLoggedIn:
         FB.Connect.requireSession();
     alert('There was an error logging in.');
      }
   });
  });
</script>
{% endhighlight %}

_Verifying the Signature_

FacebookConnect.aspx does the job at performing a cross-site Facebook login, then redirects back to the initial login page. The latter must now verify that the login is legit and locate a FoodCandy account associated with this Facebook login. I do this work in the actual login page.

If you’re doing all of this on the client side, read [this document](https://web.archive.org/web/20091223093524/https://wiki.developers.facebook.com/index.php/Verifying_The_Signature) for background and use the [Facebook Connect library](https://web.archive.org/web/20100522114321/https://fbconnectauth.codeplex.com/). I had to split the process between the front-end and the back-end and used it for a reference implementation.

Facebook cookies are collected in a sorted list, concatenated and signed.

{% highlight c# %}
public SortedList<string, string> GetFacebookCookies(HttpCookieCollection cookies)
{
    SortedList<string, string> sortedCookies = new SortedList<string, string>();
    string cookiePrefix = FacebookAPIKey + "_";
    foreach (string cookieName in cookies)
    {
        if (cookieName.StartsWith(cookiePrefix))
        {
            var cookie = cookies[cookieName];
            sortedCookies.Add(cookie.Name.Substring(cookiePrefix.Length), cookie.Value);
        }
    }

    return sortedCookies;
}
{% endhighlight %}

The signature must match the value of the cookie with the same name as the API key.

{% highlight c# %}
var sb = new StringBuilder();
foreach (String s in cookies.AllKeys)
{
    sb.AppendFormat("{0}={1}", s, cookies[s]);
}

sb.Append(facebookSecret);
string stringToHash = sb.ToString();

StringBuilder computedHash = new StringBuilder();
byte[] hash = MD5.Create().ComputeHash(Encoding.UTF8.GetBytes(stringToHash));
foreach (byte b in hash)
{
    computedHash.AppendFormat("{0:x2}", b);
}

return computedHash.ToString().ToLowerInvariant() == signature.ToLowerInvariant();
{% endhighlight %}

_Facebook Account Id to FoodCandy Account Id_

Once the signature is verified, you can trust the Facebook user id stored in the "user" cookie. It’s a 64-bit integer. I created a new table in SnCore called _AccountFacebook_ and allow users to associate facebook IDs with their account. If the back-end can locate such an account, an SnCore login ticket is issued, which completes the login operation.

{% highlight c# %}
AccountFacebook account = (AccountFacebook)session.CreateCriteria(typeof(AccountFacebook))
        .Add(Expression.Eq("FacebookAccountId", FacebookAccountId))
        .UniqueResult();
{% endhighlight %}

#### FoodCandy Signup with Facebook

The signup process first goes through the same logon process as described above, except that the final landing page is one that will create an account. Most of what I describe below is well explained [here](https://web.archive.org/web/20160315103809/http://devtacular.com/articles/bkonrad/how-to-retrieve-user-data-from-facebook-connect-in-aspnet/), albeit for an older version of the API. This should serve as a refresher.

First, I got hold of the [Facebook Developer Toolkit](https://web.archive.org/web/20100531012447/https://facebooktoolkit.codeplex.com/) that implements calls to Facebook using the [Facebook Graph API](https://developers.facebook.com/docs/api). It is initialized with the API key, the secret and a session key. The toolkit is going to be making server-to-server calls from FoodCandy to Facebook, it’s all back-end operation.

{% highlight c# %}
Facebook.Session.ConnectSession facebookSession = new Facebook.Session.ConnectSession(
    FacebookAPIKey, FacebookSecret);

facebookSession.SessionKey = facebookCookies["session_key"];
facebookSession.UserId = long.Parse(facebookCookies["user"]);
Facebook.Rest.Api facebookAPI = new Facebook.Rest.Api(facebookSession);
{% endhighlight %}

At signup I need the user’s name, e-mail and birthday. I’d also like to get the user’s location and maybe even a picture.

{% highlight c# %}
Facebook.Schema.user user = facebookAPI.Users.GetInfo();

TransitAccount ta = new TransitAccount();
ta.Name = user.name;
ta.Birthday = DateTime.Parse(user.birthday_date);
acct.CreateWithFacebook(t_facebook.FacebookAccountId, user.proxied_email,
    ta, ManagedAccount.GetAdminSecurityContext(session));

if (user.current_location != null)
{
    ta.City = user.current_location.city;

    int country_id;
    if (ManagedCountry.TryGetCountryId(session, user.current_location.country, out country_id))
        ta.Country = user.current_location.country;

    int state_id;
    if (ManagedState.TryGetStateId(session, user.current_location.state, user.current_location.country, out state_id))
        ta.State = user.current_location.state;
}

if (user.picture_big != null)
{
    TransitAccountPicture t_picture = new TransitAccountPicture();
    t_picture.AccountId = acct.Id;
    ThumbnailBitmap bitmap = new ThumbnailBitmap(new Bitmap(user.picture_big));
    t_picture.Bitmap = bitmap.Bitmap;
    t_picture.Thumbnail = bitmap.Thumbnail;
    t_picture.Name = user.pic;
    ManagedAccountPicture m_picture = new ManagedAccountPicture(session);
    m_picture.CreateOrUpdate(t_picture, ManagedAccount.GetAdminSecurityContext(session));
}

SnCore.Data.Hibernate.Session.Flush();
return acct.Id;
{% endhighlight %}

That’s a lot of private information that you gave me with a single click! Let's look at the created account.

![]({{ site.url }}/images/posts/2010/2010-05-07-foodcandycom-implementing-facebook-connect-and-signup-w-graph-api/image_25.jpg)

Try it! Signup to FoodCandy with a Facebook account.

![facebook]({{ site.url }}/images/posts/2010/2010-05-07-foodcandycom-implementing-facebook-connect-and-signup-w-graph-api/facebook_15.jpg)

#### Links

- [FacebookConnect.aspx](https://github.com/dblock/sncore/blob/master/SnCore.Web/FacebookConnect.aspx)
- [FacebookConnect.aspx.cs](https://github.com/dblock/sncore/blob/master/SnCore.Web/FacebookConnect.aspx.cs)
- [FacebookPageManager.cs](https://github.com/dblock/sncore/blob/master/SnCore.Web/App_Code/FacebookPageManager.cs)
