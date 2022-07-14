import 'package:rest_simplified/beans.dart';
import 'package:rest_simplified/parsers_factory.dart';
import 'package:rest_simplified/rest_accessor.dart';
import 'package:rest_simplified/rest_simplified.dart';
import 'package:test/test.dart';

void main() {
  test('Should not fail', () async {
    RestSimplified rs = RestSimplified.build('https://catfact.ninja');
    rs.addFromJsonMapParser<CatFact>(CatFactJsonMapper());
    rs.addPath<CatFact>(Method.get, '/fact');

    ServiceResult result = await rs.getRestAccessor().get<CatFact>();
    expect(result.httpCode, 200);

    CatFact catFact = result.entity;

    expect(catFact.fact!.length, catFact.length);
    print(catFact.fact);
  });

  test('Get simple string', () async {
    RestSimplified rs = RestSimplified.build('https://catfact.ninja');
    rs.addPath<String>(Method.get, '/fact');

    ServiceResult result = await rs.getRestAccessor().get<String>();
    expect(result.httpCode, 200);

    print(result.entity);
  });
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
