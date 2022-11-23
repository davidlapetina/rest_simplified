## Simple Rest get example
```dart
void getExampleCall() async {

 RestSimplified rs = RestSimplified.build('https://catfact.ninja');
 rs.addFromJsonMapParser<CatFact>(CatFactJsonMapper());
 rs.addPath<CatFact>(Method.get, '/fact');

 ServiceResult result = await rs.getRestAccessor().get<CatFact>();

 CatFact catFact = result.entity;
 print(catFact.fact);
 print(catFact.length);
}

class CatFact {
  String? fact;
  int? length;
}

class CatFactJsonMapper implements FromJsonParser {
  @override
  List toList(json) {
    //No list
    throw UnimplementedError();
  }

  @override
  toObject(Map<String, dynamic> json) {
    CatFact fact = CatFact();
    fact.fact = json['fact'];
    fact.length = json['length'];
    return fact;
  }
}
```

### Example with Post request for login then get to display some information
```dart
//A header
class JSONContentHeader implements HeaderBuilder {
  @override
  Map<String, String> get() {
    Map<String, String> header = {};
    header['Content-Type'] =
        'application/json'; //Might be necessary depending on the server-side
    return header;
  }
}
//Another header could be 
/*
class HeaderBuilder {
  Map<String, String> get() {
    Map<String, String> header = {};
    header['Content-Type'] = 'application/json';
    header['authorization'] = 'Bearer ' + aToken;
    return header;
  }
}
*/

class RestFactory {
  static final RestSimplified rest = RestSimplified.build(
      'http://localhost:3000',
      defaultHeaderBuilder: JSONContentHeader());

  //To be called in main.dart before any widget displayed use the static variable above
  static void init() {
    rest.addFromJsonMapParser<UserDTO>(UserJsonToUser());
    rest.addToJsonMapParser<SigninDTO>(SigninToJson());
    //For each path we can post/put only one DTO, or get only one as well
    //It should not be an issue but in case you want to do something like:
    // - restSimplified.addPath<UserDTO>(Protocol.get, '/users/whoami/');
    // - restSimplified.addPath<UserDTO>(Protocol.get, '/users/myinformation/');
    // You need to either use another DTO (and serializers as well) and end up with
    // - restSimplified.addPath<UserDTO>(Protocol.get, '/users/whoami/');
    // - restSimplified.addPath<UserInformationDTO>(Protocol.get, '/users/myinformation/');
    // Or you can instantiate another instance of RestSimplified and reuse both Serializers and DTOs
    // - restSimplified.addPath<UserDTO>(Protocol.get, '/users/whoami/');
    // - otherRestSimplified.addPath<UserDTO>(Protocol.get, '/users/myinformation/');
    // Not that when doing post/put the return type can change even if it should not happen
    rest.addPath<SigninDTO>(Method.post, '/users/signin');
    rest.addPath<UserDTO>(Method.get, '/users/whoami/');
  }
}

class SigninDTO {
  String email;
  String password;
  SigninDTO(this.email, this.password);
}

class UserDTO {
  String? email;
  String? recoveryEmail;
  String? publicKey;
}

class SigninToJson extends ToJsonMapParser<SigninDTO> {
  @override
  Map<String, String> toMap(SigninDTO dto) {
    Map<String, String> map = {};
    map['email'] = dto.email;
    map['password'] = dto.password;
    return map;
  }
}

//In case serialization and deserialization is needed, either write two classes
//or extends both FromJsonParser and ToJsonMapParser
class UserJsonToUser extends FromJsonParser<UserDTO> {
  @override
  UserDTO toObject(Map<String, dynamic> json) {
    UserDTO user = UserDTO();
    user.email = json['email'];
    user.recoveryEmail = json['recoveryEmail'];
    user.publicKey = json['publicKey'];
    return user;
  }
}

//In a LoginWidget

//Called when pressing the form button
void _call(Map<String, dynamic> form) {
  SigninDTO signin = SigninDTO(form['email'], form['password']);
  Future<ServiceResult> result = RestFactory.rest
      .getRestAccessor()
      .post<SigninDTO, UserDTO>(signin, headerBuilder: JSONHeader());
  result.then((value) => _handleResponse(value.entity, value.headers));
}

void _handleResponse(UserDTO entity, Map<String, String> headers) {
  //Here we can do additional checkings if needed
  //NB: when debugging locally in Android Studio we need to activate CORS
  //Also if authentication/session are managed by cookies CORS might create troubles 
  SimpleRouter.forwardAndRemoveAll(const WhoAmIPage()); //Example with SimpleROuter
}

//In the widget to display information for UserDTO
@override
void initState() {
  //We do not need any header, flutter web will manage the cookie for us
  Future<ServiceResult> whoami =
  RestFactory.rest.getRestAccessor().get<UserDTO>();
  whoami.then((value) => _handleResult(value.entity));
  super.initState();
}

void _handleResult(UserDTO user) {
  //Update fields' values that will be displayed on the screen
  setState(() {
    _email = user.email ?? '';
    _recoveryEmail = user.recoveryEmail ?? '';
    _publicKey = user.publicKey ?? '';
    _loading = false;
  });
}


```
