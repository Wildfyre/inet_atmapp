Application transfer protocol
=============================

Updated august 2015.

## The basic program concept

The program is built to be a complete server-client ATM program. An user can
through a terminal withdraw and deposit pretendo-money through user-driven 
transactions.. Accessing funds require a login (UID+PIN) and a verification fo 
each transaction. Funds are stored on a client-independant server. 

As this is an exercise assignment around
understanding sockets, there is no saftey mechanisms what so ever outside the 
client input checks. Period. This also means that if you run the server with any
client than the provided (or vice versa) it's likely to crash horrendously. If
so: good on you, mate.

### Division of code

To minimize the amount of traffic between the server and client most logic is 
handled on within the server. All communications consists of four requests from
the client to the server, sending a 10-byte string and recieving one in 
exchange. The request types are specified below. 

## Requests

There are five (six really, counting debug stuff) types of requests: LOG 
(Login), TRA (Transaction), VER (Verification),  BAN (Banner) and EXT (Exit). There is also a
sixth request type called DBG (Debug) to check that the server-client link 
works.

### Request structure

Due to the assignments parameter that no transmission between server and client
may exceed 10 bytes, each request is The general stucture of a client request 
can in fact consist of several separate transmissions, each followed by a line 
terminator. Each request is initiated by a three-letter identifyer and is 
followed by a varying number of additional parameters based on the three-letter 
request idenifyer. These identifyers are either is etiher LOG, TRA, VER, BAN, EXT or
DBG.

### Request sequencing
Since the client-server pair is built with the logic on the client-side, the server
handles each request separately and can handle them in any order. Fot the server to 
be able to initialize the user session however, before a LOG-request has been 
successfully made, all TRA and VER requests wil return FLD automatically.

### The LOG (Login) request

The login request is used to load a users data into the server side of the 
server-client connection. The client also gives the user access to user menu 
after getting a positive response from the server to the LOG request.

The login request is the equivalen of inserting your card into an ATM machine.

#### Parameters

The Login request is initiated with the 'LOG' identifyer and takes **two** 
additional parameters. 

The first parameter is an eight-digit numerical string 
representing the users unique card number. This parameter is referred to as 
'UID'.

The second paramareter is an four-digit numerical string representing the users 
PIN. This parameter is referred to as 'PIN'.

#### Response

The login response generates a three-letter response: "SCS" for success and "FLD" for failed. 

#### Examples

> **Client:**   'LOG'  
> **Client:**   '12345678'  
> **Client:**   '1234'  
> **Server:**   'SCS'  

### The TRA (Transaction) request

The transaction request is used for withdrawals, deposits and balance checks for
the funds on the account. The transaction request is used to confirm a users 
identity in the case of withdrawals by demanding a pre-sent numerical code.

#### Parameters

The transaction request isninitiated by the 'TRA' identifyer and takes **one** 
additional parameter. 


The first parameter is a eight-digit numerical string representing the change in
balance that is requested. A positive number represents a deposit, a negative 
number represents a withdrawal and a 0 represents a balance check. 

#### Response

The response of the transaction request is an eight-digit number representing 
the new account balance. If the funds on the account does not prepit the 
requested change, a 'FLD' (failed) identifyer is returned.

#### Examples

User depositing 1000 in an empty account.
> **Client:**   'TRA'  
> **Client:**   '1000'  
> **Server:**   '1000'

User withdrawing 400 from same account.
> **Client:**   'TRA'  
> **Client:**   '-400'  
> **Server:**   '600'

User trying to withdraw 1000 from same account.
> **Client:**   'TRA'  
> **Client:**   '-1000'  
> **Server:**   'FLD'

User checking current balance.
> **Client:**   'TRA'  
> **Client:**   '0'  
> **Server:**   '600'

### The VER (Verification) request

The verification request is used to verify withdrawals. The user is prompted to 
enter a pre-distributed numerical code to varify their identity. Note that there 
are no requirements on the server side for any verifications.As with all user 
patterns in this application, the responsibility rests with the client alone.

#### Parameters

The verifiaction request is initiated with the 'VER' identifyer and takes **one**
additional parameter.

The first parameter is a four-digit numerical string representing the pre-sent 
numerical verification code. This parameter is referred to as 'VC'.

#### Response

The verification request always returns a 'boolean' string: either 'SCS' 
(Success) or FLD (Failed) depending on the serverside comparison towards the 
expected value.

#### Example

User trying to verify a transaction.
> **Client:**   'VER'  
> **Client:**   '03'  
> **Server:**   'FLD'

User trying to verify a transaction.
> **Client:**   'VER'  
> **Client:**   '05'  
> **Server:**   'SCS'

### The BAN (Banner) request

The banner request is made to check if the welcome message (banner) on the 
client is up to date. 

#### Parameters

The banner request is initiated with the 'BAN' identifyer and takes **one**
additional parameter.

The first parameter is a four-letter string representing the beginning of the 
current banner message hash value, called banner-id. This is compared to the 
"latest message" on 
the server.

#### Response

The banner request is either a 'SCS' (success) string if the banner-id revealed 
the current message as up-to-date.

If the comparisons fails (the banner is out of date) the new banner is returned 
as a string.

#### Example

Client checking an out of date banner.
> **Client:**   'BAN'  
> **Client:**   '5847'  
> **Server:**   'Please ask your personal banker about our great prices on 
houses in Florida!'

Client checking an up to date banner.
> **Client:**   'BAN'  
> **Client:**   '9274'  
> **Server:**   'SCS'

### The EXT (Exit) request

The exit request is used to terminate the client-server connection. It takes no parameters and is sent when the client side is disengaging, as the user logs out.

#### Parameters

The exit request takes no parameters.

#### Response

The server sends a simple "SCS" string and will take no more requests from the client.

#### Example

> **Client:**   'EXT'  
> **Server:**   'SCS'

### The DBG (Debug) request

The debug request is used to verify a working connection on the most basic 
level. It sends a string and recieves one in return.

#### Parameters

The debug request takes no parameters.

#### Response

The debug request should always be responded with a time-object string.

#### Example

> **Client:**   'DBG'  
> **Server:**   '2014-05-15 09:22:21 -0400'

