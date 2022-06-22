import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rest_simplified/beans.dart';

/// Simple mixin to help you manage async calls in your widget.
mixin RestCallResponseManagement<T extends StatefulWidget> on State<T> {
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

  /// Main method to call for instance when a button is clicked.
  /// example:
  /// [setValueOrDisplayError](restSimplified.get<Car>(), _setCurrentCar, _restCallException, myAdditionalParam);
  /// With:
  /// _setCurrentCar(Car carFetched)
  /// In case additionalParam is provided then we call _setCurrentCar(carFetched, myAdditionalParam);
  /// This additional param is useful when several rest call are needed (example get a customer, then get the car but we still need the customer in the callback.
  /// _restCallException(dynamic value) //TODO
  ///
  void setValueOrDisplayError(Future<ServiceResult> futureServiceResult,
      Function setter, Function errorHandler,
      {var additionalParam}) {
    futureServiceResult.then((value) => {
          _callBackSet(setter, errorHandler, value,
              additionalParam: additionalParam)
        });
    futureServiceResult.catchError((error) {
      return ServiceResult.onInternalError(error.toString());
    });
  }
}
