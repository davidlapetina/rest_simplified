Rest Simplified is a simple library to help accessing a REST Full backend.

The current version is experimental. Do not use it for production yet.

Example, used for test:
    
    RestSimplified rs = RestSimplified.build('https://catfact.ninja');
    rs.addFromJsonMapParser<CatFact>(CatFactJsonMapper());
    rs.addPath<CatFact>(Protocol.get, '/fact');

    ServiceResult result = await rs.getRestAccessor().get<CatFact>();
    expect(result.httpCode, 200);

    CatFact catFact = result.entity;

    expect(catFact.fact!.length, catFact.length);
    print(catFact.fact);
