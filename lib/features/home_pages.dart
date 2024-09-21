import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pulparambil/features/page_five.dart';
import 'package:pulparambil/features/page_foure.dart';
import 'package:pulparambil/features/page_one.dart';
import 'package:pulparambil/features/page_three.dart';
import 'package:pulparambil/features/page_two.dart';
import 'package:pulparambil/main.dart';

List<Map<String, dynamic>> text = [
  {'text': 'Live rate', 'icon': Icon(Icons.bar_chart, color: Color(0xFFBFA13A), size: 30)},
  {'text': 'Rate Alert', 'icon': Icon(Icons.notifications_active, color: Color(0xFFBFA13A), size: 30)},
  {'text': 'News', 'icon': Icon(Icons.new_releases, color: Color(0xFFBFA13A), size: 30)},
  {'text': 'About Us', 'icon': Icon(Icons.person, color: Color(0xFFBFA13A), size: 30)},
  {'text': 'Bank Details', 'icon': Icon(Icons.maps_home_work_rounded, color: Color(0xFFBFA13A), size: 30)},
  {'text': 'Coming Soon', 'icon': Icon(Icons.add_circle_sharp, color: Color(0xFFBFA13A), size: 30)},
];

List<Widget> pages = [
  PageOne(),
  Pagetwo(),
  Pagethree(),
  Pagefoure(),
  Pagefive(),
];

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  Color(0xFF1F0B0A),
        title: Text('Pulparambil', style: TextStyle(fontStyle: FontStyle.normal,color: Colors.white)),
      ),
      body: Container(height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/images/pul.png'),
            fit: BoxFit.cover, // Cover the entire body area
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 90),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 1.2,
            ),
            itemCount: text.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.0),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (index < pages.length) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => pages[index]),
                    );
                  } else {
                    print('Page index out of bounds');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      text[index]['icon'],
                      SizedBox(height: 10),
                      Text(
                        text[index]['text'],
                        style: GoogleFonts.urbanist(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
