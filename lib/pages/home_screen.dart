import 'package:autoformation_app/app_router.dart';
import 'package:autoformation_app/models/quiz.dart';
import 'package:autoformation_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Future<List<Quiz>> _quizzes;
  var currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _quizzes = ApiService().fetchQuizzes();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black, // Couleur de fond
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          "EPAF l'APP",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Action pour la recherche
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/icon/app_home.webp'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.darken,
                  )),
            ),
            child: Column(
              children: [
                Text(
                  'Bienvenue au Quiz App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Rechercher un quiz...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // GridView pour les catégories
          Expanded(
            child: FutureBuilder<List<Quiz>>(
              future: _quizzes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Aucune catégorie disponible'));
                } else {
                  return GridView.count(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: snapshot.data!
                        .map((quiz) => _buildCategoryCard(quiz.title, quiz.uuid,
                            quiz.module.illustration, Icons.book, context))
                        .toList(),
                  );
                }
              },
            ),
          ),
        ],
      ),
      // Barre de navigation inférieure
      // bottomNavigationBar: Container(
      //   margin: EdgeInsets.all(20),
      //   height: size.width * .155,
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(.15),
      //         blurRadius: 30,
      //         offset: Offset(0, 10),
      //       ),
      //     ],
      //     borderRadius: BorderRadius.circular(50),
      //   ),
      //   child: ListView.builder(
      //     itemCount: 4,
      //     scrollDirection: Axis.horizontal,
      //     padding: EdgeInsets.symmetric(horizontal: size.width * .024),
      //     itemBuilder: (context, index) => InkWell(
      //       onTap: () {
      //         setState(
      //           () {
      //             currentIndex = index;
      //           },
      //         );
      //       },
      //       splashColor: Colors.transparent,
      //       highlightColor: Colors.transparent,
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           AnimatedContainer(
      //             duration: Duration(milliseconds: 1500),
      //             curve: Curves.fastLinearToSlowEaseIn,
      //             margin: EdgeInsets.only(
      //               bottom: index == currentIndex ? 0 : size.width * .029,
      //               right: size.width * .0422,
      //               left: size.width * .0422,
      //             ),
      //             width: size.width * .128,
      //             height: index == currentIndex ? size.width * .014 : 0,
      //             decoration: BoxDecoration(
      //               color: Colors.blueAccent,
      //               borderRadius: BorderRadius.vertical(
      //                 bottom: Radius.circular(10),
      //               ),
      //             ),
      //           ),
      //           TextButton.icon(
      //             onPressed: () => Navigator.pushNamed(context, listOfRoutes[index]), label: Text(""), icon: Icon(
      //             listOfIcons[index],
      //             size: size.width * .076,
      //             color: index == currentIndex
      //                 ? Colors.blueAccent
      //                 : Colors.black38,
      //           )
      //           ),
      //           SizedBox(height: size.width * .03),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  List<String> listOfRoutes = [
    AppRouter.homeRoute,
    AppRouter.loginRoute,
    AppRouter.profileRoute,
    AppRouter.quizRoute,
  ];

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.book_rounded,
    Icons.message_rounded,
    Icons.person_rounded,
  ];

  // Fonction pour construire une carte de catégorie
  Widget _buildCategoryCard(String title, String uuid, String illustration,
      IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(uuid);
        Navigator.pushNamed(context, AppRouter.quizRoute, arguments: uuid);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Image SVG de fond
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.network(
                'https://dev.jem-formation.fr$illustration',
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                placeholderBuilder: (BuildContext context) => Container(
                  color: Colors.grey[850],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            // Couche sombre pour améliorer la lisibilité
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6), // Couche sombre
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Contenu de la carte (icône et texte)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Icon(icon, size: 48, color: Colors.blueAccent),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
