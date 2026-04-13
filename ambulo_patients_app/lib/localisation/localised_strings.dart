// lib/localisation/localised_strings.dart
// 
// This file provides easy access to all localised strings throughout the app.
// Import this file wherever you need localised text.
// Usage: LocalisedStrings.bookAmbulance(context)

import 'package:flutter/material.dart';
import 'package:flutter_hello_world/localisation/app_localizations.dart';

class LocalisedStrings {

  // ─── App General ───────────────────────────────────────
  static String appName(BuildContext context) =>
      AppLocalizations.of(context)!.appName;

  static String back(BuildContext context) =>
      AppLocalizations.of(context)!.back;

  static String next(BuildContext context) =>
      AppLocalizations.of(context)!.next;

  static String cancel(BuildContext context) =>
      AppLocalizations.of(context)!.cancel;

  static String confirm(BuildContext context) =>
      AppLocalizations.of(context)!.confirm;

  static String save(BuildContext context) =>
      AppLocalizations.of(context)!.save;

  static String edit(BuildContext context) =>
      AppLocalizations.of(context)!.edit;

  static String done(BuildContext context) =>
      AppLocalizations.of(context)!.done;

  static String loading(BuildContext context) =>
      AppLocalizations.of(context)!.loading;

  static String error(BuildContext context) =>
      AppLocalizations.of(context)!.error;

  static String yes(BuildContext context) =>
      AppLocalizations.of(context)!.yes;

  static String no(BuildContext context) =>
      AppLocalizations.of(context)!.no;

  static String ok(BuildContext context) =>
      AppLocalizations.of(context)!.ok;

  static String close(BuildContext context) =>
      AppLocalizations.of(context)!.close;

  // ─── Auth ───────────────────────────────────────────────
  static String enterMobileNumber(BuildContext context) =>
      AppLocalizations.of(context)!.enterMobileNumber;

  static String sendOtp(BuildContext context) =>
      AppLocalizations.of(context)!.sendOtp;

  static String verifyOtp(BuildContext context) =>
      AppLocalizations.of(context)!.verifyOtp;

  static String enterOtp(BuildContext context) =>
      AppLocalizations.of(context)!.enterOtp;

  static String resendOtp(BuildContext context) =>
      AppLocalizations.of(context)!.resendOtp;

  static String invalidOtp(BuildContext context) =>
      AppLocalizations.of(context)!.invalidOtp;

  // ─── Home Screen ────────────────────────────────────────
  static String ourServices(BuildContext context) =>
      AppLocalizations.of(context)!.ourServices;

  static String blsAmbulance(BuildContext context) =>
      AppLocalizations.of(context)!.blsAmbulance;

  static String alsAmbulance(BuildContext context) =>
      AppLocalizations.of(context)!.alsAmbulance;

  static String ambuBike(BuildContext context) =>
      AppLocalizations.of(context)!.ambuBike;

  static String lastRide(BuildContext context) =>
      AppLocalizations.of(context)!.lastRide;

  // ─── Booking ────────────────────────────────────────────
  static String bookAmbulance(BuildContext context) =>
      AppLocalizations.of(context)!.bookAmbulance;

  static String pickupLocation(BuildContext context) =>
      AppLocalizations.of(context)!.pickupLocation;

  static String dropLocation(BuildContext context) =>
      AppLocalizations.of(context)!.dropLocation;

  static String confirmAndFind(BuildContext context) =>
      AppLocalizations.of(context)!.confirmAndFind;

  static String patientCondition(BuildContext context) =>
      AppLocalizations.of(context)!.patientCondition;

  static String estimatedFare(BuildContext context) =>
      AppLocalizations.of(context)!.estimatedFare;

  // ─── Trip Flow ──────────────────────────────────────────
  static String findingNearestAmbulance(BuildContext context) =>
      AppLocalizations.of(context)!.findingNearestAmbulance;

  static String driverArriving(BuildContext context) =>
      AppLocalizations.of(context)!.driverArriving;

  static String callDriver(BuildContext context) =>
      AppLocalizations.of(context)!.callDriver;

  static String tripCompleted(BuildContext context) =>
      AppLocalizations.of(context)!.tripCompleted;

  static String totalFare(BuildContext context) =>
      AppLocalizations.of(context)!.totalFare;

  static String cancelTrip(BuildContext context) =>
      AppLocalizations.of(context)!.cancelTrip;

  // ─── Profile ────────────────────────────────────────────
  static String profile(BuildContext context) =>
      AppLocalizations.of(context)!.profile;

  static String editProfile(BuildContext context) =>
      AppLocalizations.of(context)!.editProfile;

  static String fullName(BuildContext context) =>
      AppLocalizations.of(context)!.fullName;

  static String allergies(BuildContext context) =>
      AppLocalizations.of(context)!.allergies;

  static String addAllergy(BuildContext context) =>
      AppLocalizations.of(context)!.addAllergy;

  static String allergyRemoved(BuildContext context) =>
      AppLocalizations.of(context)!.allergyRemoved;

  // ─── Settings ───────────────────────────────────────────
  static String settings(BuildContext context) =>
      AppLocalizations.of(context)!.settings;

  static String changeLanguage(BuildContext context) =>
      AppLocalizations.of(context)!.changeLanguage;

  static String selectLanguage(BuildContext context) =>
      AppLocalizations.of(context)!.selectLanguage;

  static String english(BuildContext context) =>
      AppLocalizations.of(context)!.english;

  static String hindi(BuildContext context) =>
      AppLocalizations.of(context)!.hindi;

  static String telugu(BuildContext context) =>
      AppLocalizations.of(context)!.telugu;

  static String malayalam(BuildContext context) =>
      AppLocalizations.of(context)!.malayalam;

  static String urdu(BuildContext context) =>
      AppLocalizations.of(context)!.urdu;

  static String languageChanged(BuildContext context) =>
      AppLocalizations.of(context)!.languageChanged;

  static String signOut(BuildContext context) =>
      AppLocalizations.of(context)!.signOut;

  // ─── Help & Support ─────────────────────────────────────
  static String helpAndSupport(BuildContext context) =>
      AppLocalizations.of(context)!.helpAndSupport;

  static String faq(BuildContext context) =>
      AppLocalizations.of(context)!.faq;

  static String callSupport(BuildContext context) =>
      AppLocalizations.of(context)!.callSupport;

  // ─── Errors & Status ────────────────────────────────────
  static String noInternetTitle(BuildContext context) =>
      AppLocalizations.of(context)!.noInternetTitle;

  static String sessionExpired(BuildContext context) =>
      AppLocalizations.of(context)!.sessionExpired;
}
