import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:pulparambil/Core/Utils/firebase_constants.dart';
import 'package:pulparambil/Core/Utils/firebase_provider.dart';
import 'package:pulparambil/Models/news_model.dart';

import '../../../Core/Utils/failure.dart';
import '../../../Core/Utils/type_def.dart';
import '../../../Models/commodities_model.dart';
import '../../../Models/spot_rate_model.dart';
import '../../../Models/spread_document_model.dart';

final liveRepositoryNewProvider = Provider(
  (ref) => LiveRepositoryNew(firestore: ref.watch(firestoreProvider)),
);

class LiveRepositoryNew {
  final FirebaseFirestore _firestore;
  LiveRepositoryNew({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // Future<SpreadDocumentModel> getSpread() async {
  //   print("start");
  //   DocumentSnapshot result = await _firestore
  //       .collection(FirebaseConstants.user)
  //       .doc(FirebaseConstants.userDoc)
  //       .collection(FirebaseConstants.spread)
  //       .doc(FirebaseConstants.spreadDocument)
  //       .get();
  //   print(result.data());
  //   print("end");
  //
  //   final spread =
  //       SpreadDocumentModel.fromMap(result.data() as Map<String, dynamic>);
  //   return spread;
  // }
  //
  // Stream<List<CommoditiesModel>> commodities() {
  //   return _firestore
  //       .collection(FirebaseConstants.user)
  //       .doc(FirebaseConstants.userDoc)
  //       .collection(FirebaseConstants.commodities)
  //       .snapshots()
  //       .map(
  //         (event) => event.docs.map(
  //           (e) {
  //             CommoditiesModel res = CommoditiesModel.fromMap(e.data());
  //             return res;
  //           },
  //         ).toList(),
  //       );
  // }
  //
  // Stream<NewsModel> getNews() {
  //   return _firestore
  //       .collection(FirebaseConstants.user)
  //       .doc(FirebaseConstants.userDoc)
  //       .collection(FirebaseConstants.news)
  //       .doc("ZO7Q5DeNoXszgqXLCiPA")
  //       .snapshots()
  //       .map(
  //           (event) => NewsModel.fromMap(event.data() as Map<String, dynamic>));
  // }

  FutureEither<SpotRateModel> getSpotRate() async {
    try {
      final responce = await Dio().request(
        "${FirebaseConstants.baseUrl}get-spotrates/${FirebaseConstants.adminId}",
        options: Options(headers: FirebaseConstants.headers, method: "GET"),
      );
      if (responce.statusCode == 200) {
        final spotRateModel = SpotRateModel.fromMap(responce.data);
        return right(spotRateModel);
      } else {
        return left(Failure(responce.statusCode.toString()));
      }
    } on DioException catch (e) {
      print(e.error);
      print(e.stackTrace);
      print(e.message);
      print(e.response);
      return left(Failure("Dio EXCEPTION"));
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return left(Failure(e.toString()));
    }
  }
}
