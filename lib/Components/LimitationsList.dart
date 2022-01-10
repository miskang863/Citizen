import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LimitationsList {
  var listOfLimitations = [
    "limitation_physicallyChallenged".tr(),
    "limitation_visualImpairment".tr(),
    "limitation_hearingDisabled".tr(),
  ];

  var mapOfLimitationIcons = {
    "limitation_physicallyChallenged".tr(): Icons.elderly_sharp,
    "limitation_visualImpairment".tr(): Icons.visibility_off_outlined,
    "limitation_hearingDisabled".tr(): Icons.hearing_disabled
  };
}
