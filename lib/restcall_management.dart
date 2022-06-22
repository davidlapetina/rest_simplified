import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rest_simplified/rest/beans.dart';

mixin RestCallResponseManagement<T extends StatefulWidget> on State<T> {
  void handleException(Exception exception);

  void _callBackSet(
      Function setter, Function errorHandler, ServiceResult serviceResult,
      {var additionalParam}) {
    if (ServiceExecutionResult.success == serviceResult.result) {
      if (additionalParam == null) {
        setter(serviceResult.entity);
      } else {
        setter(serviceResult.entity, additionalParam);
      }
      return;
    }

    errorHandler(serviceResult.entity);
  }

  void setValueOrDisplayError(Future<ServiceResult> futureServiceResult,
      Function setter, Function errorHandler,
      {var additionalParam}) {
    //print("in setValueOrDisplayError " + setter.toString());
    futureServiceResult.then((value) => {
          _callBackSet(setter, errorHandler, value,
              additionalParam: additionalParam)
        });
    futureServiceResult.catchError((error) {
      handleException(error);
      return ServiceResult.onInternalError(error.toString());
    });
  }
}
