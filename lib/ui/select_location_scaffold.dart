
import 'package:flutter/material.dart';
import 'package:flutterbasetaxi/api/google_api.dart';
import 'package:flutterbasetaxi/types/resolved_address.dart';
import 'package:flutterbasetaxi/ui/address_search.dart';
import 'package:flutterbasetaxi/providers/location.dart';
import 'package:flutterbasetaxi/ui/common.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:lottie/lottie.dart';

class LocationScaffold extends StatelessWidget {
  LocationScaffold({Key? key}) : super(key: key);

  final demoAddressNewYork = ResolvedAddress(
      location: Location(lat: 14.7667, lng: -17.2833),
      mainText: "DAKAR , SENEGAL",
      secondaryText: "DKR, SEN");

  final demoAddressLondon = ResolvedAddress(
      location: Location(lat: 14.866667, lng: -15.883333),
      mainText: "TOUBA, SENEGAL",
      secondaryText: "TOUB, SEN");

  final demoAddressParis = ResolvedAddress(
      location: Location(lat: 16.237997, lng: -16.212559),
      mainText: "ST-LOUIS, SENEGAL",
      secondaryText: "STL, SEN");

  void _setDemoLocation(BuildContext context, ResolvedAddress address) {
    final locProvider = LocationProvider.of(context, listen: false);
    locProvider.currentAddress = address;
    showScaffoldSnackBarMessage(
        '${address.mainText} was set as a current location.');
  }

  void _selectCurrentLocation(BuildContext context) async {
    final Prediction? prd = await showSearch<Prediction?>(
        context: context, delegate: AddressSearch(), query: '');

    if (prd != null) {
      PlacesDetailsResponse placeDetails = await apiGooglePlaces
          .getDetailsByPlaceId(prd.placeId!, fields: [
        "address_component",
        "geometry",
        "type",
        "adr_address",
        "formatted_address"
      ]);

      final address = ResolvedAddress(
          location: placeDetails.result.geometry!.location,
          mainText: prd.structuredFormatting?.mainText ??
              placeDetails.result.addressComponents.join(','),
          secondaryText: prd.structuredFormatting?.secondaryText ?? '');

      final locProvider = LocationProvider.of(context, listen: false);
      locProvider.currentAddress = address;
      showScaffoldSnackBarMessage(
          '${address.mainText} was set as a current location.');

      showScaffoldSnackBarMessage(
          placeDetails.result.geometry?.location.lat.toString() ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool pendingDetermineLocation =
        LocationProvider.of(context).pendingDetermineCurrentLocation;
    return buildAppScaffold(
        context,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(left: 64, top: 8),
              child: Text(
                "Flutterbase demo",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Expanded(child: Lottie.asset('assets/lottie/taxi-animation.json')),
            if (pendingDetermineLocation) ...[
              LinearProgressIndicator(),
              Text('Please wait while your prosition is determined....'),
            ],
            if (!pendingDetermineLocation) ...[
              Text(
                'Choose your location',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('TOUBA , SENEGAL'),
                subtitle: Text("GRANDE MOSQUEE"),
                onTap: () => _setDemoLocation(context, demoAddressNewYork),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('PIKINE DAKAR , SENEGAL'),
                subtitle: Text("EDK PIKINE"),
                onTap: () => _setDemoLocation(context, demoAddressLondon),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('ST-LOUIS , DAKAR'),
                subtitle: Text("PONT FAIDHERBE"),
                onTap: () => _setDemoLocation(context, demoAddressParis),
                trailing: Icon(Icons.chevron_right),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Search location by name'),
                onTap: () => _selectCurrentLocation(context),
              ),
              ListTile(
                leading: Icon(Icons.gps_fixed),
                title: Text('Dertemine my location by GPS'),
                onTap: () => LocationProvider.of(context, listen: false)
                    .determineCurrentLocation(),
              )
            ],
          ]),
        ),
        isLoggedIn: false);
  }
}
