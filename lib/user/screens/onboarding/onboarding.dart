import 'package:flutter/material.dart';
import 'package:petaholic/user/screens/authentication/login.dart';
import 'content_model.dart';

class Onbording extends StatefulWidget {
  @override
  _OnbordingState createState() => _OnbordingState();
}

class _OnbordingState extends State<Onbording> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 86, 99),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bgscreen1.png', // Background image
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              SizedBox(height: 40),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          // Replacing SVG with Image.asset
                          Image.asset(
                            contents[i].image, // Ensure these are PNG or JPG
                            height: 300,
                          ),
                          SizedBox(height: 15),
                          Text(
                            contents[i].title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            contents[i].discription,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    contents.length,
                    (index) => buildDot(index, context),
                  ),
                ),
              ),
              Container(
                height: 60,
                margin: EdgeInsets.all(40),
                width: double.infinity,
                child: TextButton(
                  child: Text(currentIndex == contents.length - 1
                      ? "Get Started"
                      : "Next"),
                  onPressed: () {
                    if (currentIndex == contents.length - 1) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(),
                        ),
                      );
                    }
                    _controller.nextPage(
                      duration: Duration(milliseconds: 100),
                      curve: Curves.bounceIn,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 255, 255, 255),
      ),
    );
  }
}
