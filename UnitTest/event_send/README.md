# event:send testing for picos related by subscription

KRL includes a built-in `event` module.
The module provides a `send` action
(see documentation page "[event](https://picolabs.atlassian.net/wiki/spaces/docs/pages/1189929/event)").

It has been suggested that an alternate form of `event:send` could allow the KRL programmer to specify
a subscription identifier instead of an event channel identifier (ECI).

## Test setup

The setup will be a test pico and two other picos to which it is related by subscription;
the test pico will play the role of `"petitioner"` while the other picos will play the role of `"responder"`.

A simple setup will look something like this:

![simple setup](./subscriptions.png)

### Simple setup

Create the test pico, make subscriptions between it and two other picos, and add a new channel for testing purposes.

1. Make a test pico named, say, "Try test.event_send.sub"
2. Make a note of its wellKnown_Rx channel identifier (say, cld0li17e002ba5mbcq3l2q7k) from the Channels tab or the Subscriptions tab (shown below)

![wellKnown_Rx](./wellKnown_Rx.png)

3. Choose two other picos, named whatever
4. In each of their Subscriptions tabs, make a new subscription:
    1. wellKnown_Tx: the wellKnown_Rx of the test pico, e.x. cld0li17e002ba5mbcq3l2q7k
    2. Rx_role: responder
    3. Tx_role: petitioner
    4. name: test.event_send.eci
    5. channel_type: subscription
    6. Tx_host: leave blank
    7. password: leave blank
5. In the Subscriptions tab of the test pico, accept both Inbound subscriptions
6. In the Channels tab, create a new channel, shown below
    1. Tagged test.event_send.eci
    2. Allowing event petitioner:has_answered

![new channel](./newChannel.png)

### More complex setup

Have at least one of the picos be hosted by a pico engine running in a different domain and/or port.
This would more fully test the `event:send` operations.
But the first test wouldn't run as written, as the `host` argument would need to be known.

## Tests

First, a regression unit test to ensure that `event:send` works as presently constituted.
Then, a TDD test to show that the new form doesn't work.
This second test can double as a regression test, once the feature has been implemented.
Then, another TDD test to show that passing in the entire subscription map doesn't work.
This third test doubles as a regression test, once the entire map feature has been implemented.

### Testing the use of an ECI in `event:send`

7. In Rulesets tab of test pico, install the [test.event_send.eci](https://raw.githubusercontent.com/b1conrad/KRL-experiments/main/UnitTest/event_send/test.event_send.eci.krl) ruleset from this repo
8. In Testing tab of test pico, select new channel, and click the `petitioner:has_answered` button
9. Using the Logging tab, check to see that both related picos received the event and that no other pico has received it

### Testing the use of a subscription identifier in `event:send`

1. In Rulesets tab of test pico, delete the `test.event_send.eci` ruleset from this repo
2. Install the [`test.event_send.sub`](https://raw.githubusercontent.com/b1conrad/KRL-experiments/main/UnitTest/event_send/test.event_send.sub.krl) ruleset
3. Repeats steps 8 and 9 of the ECI test and the results should be the same, noting that is one of the other picos may be on a different host

#### Difference between the two KRL rulesets

```
$ diff UnitTest/event_send/test.event_send.*
1c1
< ruleset test.event_send.eci {
---
> ruleset test.event_send.sub {
14c14
<     event:send({"eci":s{"Tx"},"eid":"none",
---
>     event:send({"sub":s{"Id"},"eid":"none",
```

### Testing the use of an entire subscription map in `event:send`

1. In Rulesets tab of test pico, delete the `test.event_send.sub` ruleset
2. Install the [`test.event_send.sub_map`](https://raw.githubusercontent.com/b1conrad/KRL-experiments/main/UnitTest/event_send/test.event_send.sub_map.krl) ruleset from this repo
3. Repeats steps 8 and 9 of the ECI test and the results should be the same, noting that is one of the other picos may be on a different host

#### Differences between the two subscription-based KRL rulesets

```
$ diff UnitTest/event_send/test.event_send.sub*
1c1
< ruleset test.event_send.sub {
---
> ruleset test.event_send.sub_map {
13,14c13,14
<     foreach subs:established().filter(resp) setting(s)
<     event:send({"sub":s{"Id"},"eid":"none",
---
>     foreach subs:established().filter(resp) setting(a_sub)
>     event:send({"sub":a_sub,"eid":"none",
16c16
<       "attrs":event:attrs},s{"Tx_host"})
---
>       "attrs":event:attrs})
```
