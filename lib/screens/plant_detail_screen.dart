import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class PlantDetailsScreen extends StatelessWidget {
  final String plantName;
  final String imageUrl;
  final String plantDescription;
  final List<String> commonNames;
  final List<String> edibleParts;
  final List<String> propagationMethods;
  final Map<String, dynamic> watering;
  final String wikiUrl;

  PlantDetailsScreen({
    required this.plantName,
    required this.imageUrl,
    required this.plantDescription,
    required this.commonNames,
    required this.edibleParts,
    required this.propagationMethods,
    required this.watering,
    required this.wikiUrl,
  });

  /// Returns a watering tip based on watering frequency.
  /// When watering['max'] == 0, the plant needs daily watering ("Water Often");
  /// otherwise, it needs watering rarely.
  String _getWateringTipBasedOnFrequency() {
    if (watering['max'] == 0) {
      return "Tip: Daily watering helps maintain optimal soil moisture.";
    } else {
      return "Tip: Allow the soil to dry out between waterings to prevent root rot.";
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plant image
                Container(
                  height: screenHeight * 0.45,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                // Plant details container (overlaying the bottom of the image)
                Transform.translate(
                  offset: Offset(0, -30),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tags row
                        Row(
                          children: [
                            _buildTag("0 sites available", Colors.orange),
                            const SizedBox(width: 8),
                            _buildTag("Not recommended", Colors.red),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Plant name
                        Text(
                          plantName,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Common names chips
                        _buildCommonNamesChips(),
                        const SizedBox(height: 8),
                        // Description
                        Text(
                          plantDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Plant details sections: edible parts, watering, propagation
                        _buildPlantDetails(),
                        const SizedBox(height: 20),
                        _buildWikiButton(wikiUrl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Positioned icons (close and share)
          Positioned(
            top: 40,
            left: 10,
            child: _buildIconButton(Icons.close, () => Navigator.pop(context),
                isCircular: true),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: _buildIconButton(Icons.share, () {}, isCircular: false),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildPlantDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEdiblePartsSection(),
        const SizedBox(height: 12),
        // Watering Needs section
        _buildWateringNeedsSection(),
        const SizedBox(height: 12),
        // Propagation Methods section with detailed UI and explanation
        _buildPropagationSection(),
      ],
    );
  }

  /// Watering section with a gradient header, descriptive text, and a dynamic tip.
  Widget _buildWateringNeedsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Subtle background gradient
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: gradient background, water icon, and bold title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: watering['max'] == 0
                    ? [Colors.green.shade400, Colors.green.shade400]
                    : [Colors.green.shade400, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(MdiIcons.water, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  watering['max'] == 0 ? "Water Often" : "Rarely Water",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Watering description text
          Text(
            watering['max'] == 0
                ? "Water every 3-4 days to keep the soil moist."
                : "Water every 2 weeks or more, allowing the soil to dry out between waterings.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          // Dynamic watering tip based on frequency
          Text(
            _getWateringTipBasedOnFrequency(),
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Propagation Methods section styled similarly to the watering section.
  /// This section includes a header with a gradient background and seed icon,
  /// a brief explanation of what propagation methods are, and a list of methods.
  Widget _buildPropagationSection() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(MdiIcons.seed, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Propagation Methods",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          _buildList(propagationMethods),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: propagationMethods.map((method) {
              return _getPropagationMethodDescription(method);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _getPropagationMethodDescription(String method) {
    switch (method.toLowerCase()) {
      case "seeds":
        return _buildPropagationMethodDetails(
          "Seeds",
          "To propagate using seeds:\n\n"
              "1. Collect mature seeds from the parent plant. This usually happens after flowering or fruiting. "
              "2. Prepare a seed tray or small pots with well-draining, moist potting soil.\n\n"
              "3. Scatter the seeds over the soil and lightly cover them with a thin layer of soil.\n\n"
              "4. Place the seeds in a warm, sunny spot. Keep the soil moist, but not soggy. "
              "Most seeds need a temperature of around 65-75°F (18-24°C) to germinate.\n\n"
              "5. Once the seeds sprout, allow them to grow in their container until they are strong enough to be transplanted into the garden or larger pots.",
          MdiIcons.seed,
        );
      case "cuttings":
        return _buildPropagationMethodDetails(
          "Cuttings",
          "To propagate using cuttings:\n\n"
              "1. Select a healthy stem from the parent plant. It should have a few leaves and no flowers. "
              "2. Use a sharp knife or pruning shears to cut a 4-6 inch long section of stem, just below a leaf node (where the leaf joins the stem).\n\n"
              "3. Remove the lower leaves from the cutting, leaving only a couple of leaves at the top.\n\n"
              "4. Place the cutting in water or directly into moist soil. If rooting in water, change the water every couple of days.\n\n"
              "5. After a few weeks, roots should form. Once the cutting has established a root system, transplant it into soil and treat it as a mature plant.",
          Icons.cut,
        );
      case "division":
        return _buildPropagationMethodDetails(
            "Division",
            "To propagate using division:\n\n"
                "1. Wait until the plant has grown large and established a strong root system. This method works best for clump-forming plants.\n\n"
                "2. Carefully dig up the plant and gently separate it into smaller sections, ensuring each section has roots and shoots.\n\n"
                "3. Replant the divisions into separate pots or directly into the garden. Water them thoroughly after planting to help them establish.\n\n"
                "4. Keep the divisions in a shaded area until they have settled in and started growing again.",
            MdiIcons.divisionBox);
      case "grafting":
        return _buildPropagationMethodDetails(
          "Grafting",
          "To propagate using grafting:\n\n"
              "1. Choose a healthy scion (the part of the plant you want to propagate) and a compatible rootstock (the plant's base). The rootstock should be a strong, established plant that will support the scion.\n\n"
              "2. Make a clean, angled cut on both the scion and rootstock. The cuts should match in size and shape.\n\n"
              "3. Join the scion and rootstock together, ensuring that the cambium layers (the thin layer of tissue under the bark) align perfectly.\n\n"
              "4. Secure the graft using grafting tape or rubber bands and cover the joint with wax or grafting paste to prevent drying out.\n\n"
              "5. Keep the graft in a warm, shaded area, and check for signs of growth. Once the graft has successfully fused, remove the tape and allow the plant to grow as one.",
          Icons.link,
        );
      default:
        return _buildPropagationMethodDetails(
          method,
          "Detailed instructions are not available for this method.",
          Icons.info,
        );
    }
  }

  Widget _buildPropagationMethodDetails(
      String method, String description, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.green[700]),
            const SizedBox(width: 10),
            Text(
              method,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCurvedContainer(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 6),
          ],
          content,
        ],
      ),
    );
  }

  Widget _buildCommonNamesChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: commonNames.map((name) {
        return Chip(
          label: Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEdiblePartsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Edible Parts",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: edibleParts.map((part) {
              return Row(
                children: [
                  _getIconForEdiblePart(part),
                  const SizedBox(width: 10),
                  Text(
                    part,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Icon _getIconForEdiblePart(String part) {
    switch (part.toLowerCase()) {
      case "leaves":
        return Icon(MdiIcons.leaf, size: 20, color: Colors.green[700]);
      case "seeds":
        return Icon(MdiIcons.seed, size: 20, color: Colors.green[700]);
      case "flowers":
        return Icon(MdiIcons.flower, size: 20, color: Colors.green[700]);
      default:
        return Icon(MdiIcons.flower, size: 20, color: Colors.green[700]);
    }
  }

  Widget _buildList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Text("• $item", style: const TextStyle(fontSize: 16)))
          .toList(),
    );
  }

  Widget _buildWikiButton(String url) {
    return ElevatedButton.icon(
      onPressed: () => _launchURL(url),
      icon: const Icon(Icons.open_in_browser),
      label: const Text("Read More on Wikipedia"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
    );
  }

  void _launchURL(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString(), forceWebView: true, enableJavaScript: true);
    } else {
      throw "Could not launch $url";
    }
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed,
      {bool isCircular = false}) {
    return Container(
      padding: EdgeInsets.all(isCircular ? 1 : 0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius:
            isCircular ? BorderRadius.circular(30) : BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
