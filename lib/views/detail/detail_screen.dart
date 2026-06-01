import 'package:autofinder/services/workshop/workshop_model.dart';
import 'package:autofinder/views/detail/controller/detail_controller.dart';
import 'package:autofinder/views/detail/provider/detail_page_provider.dart';
import 'package:autofinder/views/detail/widget/about_section.dart';
import 'package:autofinder/views/detail/widget/header_image_section.dart';
import 'package:autofinder/views/detail/widget/location_section.dart';
import 'package:autofinder/views/detail/widget/operational_hours_section.dart';
import 'package:autofinder/views/detail/widget/reviews_section.dart';
import 'package:autofinder/views/detail/widget/services_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:autofinder/config/app_locale.dart';
import 'package:flutter_localization/flutter_localization.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final DetailController _controller = DetailController();
  WorkshopModel? _workshop;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is WorkshopModel) {
        setState(() {
          _workshop = args;
        });
        if (_workshop?.uid != null) {
          final provider = context.read<DetailPageProvider>();
          provider.updateState(workshop: _workshop);
          _controller.fetchComments(provider, _workshop!.uid!);
        }
      }
    });
  }

  void _shareWorkshopLocation(WorkshopModel workshop) {
    final double lat = workshop.latitude;
    final double lng = workshop.longitude;

    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

    final String shareMessage =
        '''
      📍 *${workshop.title}*

      Alamat:
      ${workshop.address}

      Buka di Google Maps:
      $googleMapsUrl
      ''';

    SharePlus.instance.share(ShareParams(text: shareMessage));
  }

  @override
  Widget build(BuildContext context) {
    if (_workshop == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final provider = context.watch<DetailPageProvider>();
    final workshop = provider.state.workshop ?? _workshop!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocale.detailWorkshop.getString(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareWorkshopLocation(workshop),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderImageSection(workshop: workshop),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AboutSection(description: workshop.description),
                  const SizedBox(height: 24),
                  OperationalHoursSection(
                    operationTimes: workshop.operationTimes,
                  ),
                  const SizedBox(height: 32),
                  ServicesSection(services: workshop.services),
                  const SizedBox(height: 32),
                  LocationSection(
                    address: workshop.address,
                    phoneNumber: workshop.phoneNumber,
                    latitude: workshop.latitude,
                    longitude: workshop.longitude,
                  ),
                  const SizedBox(height: 32),
                  ReviewsSection(
                    provider: provider,
                    controller: _controller,
                    workshopId: workshop.uid ?? '',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
