Docs

    Inversed SOA (with User Management as a sample)

    I would like to ask what's the best way of make SOA. Let's take a User Management, it's a relatively simple and well known domain, and required almost in every app, but still it seems too complicated (at least for me).

    There are lots of ways to integrate user management:

    - as a gem / rails engine
    - share cookie and database
    - code generation (restful_authentication)
    - Rack middleware

    All of them require modification of application code.

    There's also another way - SOA, using standalone user management service. It also requires a little code modification and one extra http call (to the user management service).
    And this extra call also causes some problems, because in ruby it's not very easy to make such calls efficient (unless You use EventMachine or maybe jRuby).

    So, all of them, even SOA are complicated. But maybe it's possible to do the last one in reverse order? Instead of forcing app making a call reverse the control order and make the user service do it?

    I mean - by making user management service acting like a proxy and passing already processed user to app (injecting user stored as a JSON in params for example).

    Maybe we even can go further and make our SOA more ESB-like, using Message Queue as a communication channel.

    What do You think about such approach, maybe there's already some projects doing this?

    P.S. there's one big problem with such approach - IO. But it can be workaround, usually IO is only about 2-5% of application, make it also standalone service and call user management service as usual, not in reverse way.