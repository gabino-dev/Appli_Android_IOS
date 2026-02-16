import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:io';
import 'dart:async';

// =================================================================
// ⚠️ ADRESSE IP DU PARTAGE DE CONNEXION
const String PC_IP = "192.168.56.1";
// =================================================================

// --- PALETTE DE COULEURS ---
const Color kPrimaryBlue = Color(0xFF1565C0);
const Color kAccentOrange = Color(0xFFFF6F00);
const Color kBackgroundDark = Color(0xFF121212);
const Color kCardDark = Color(0xFF1E1E1E);
const Color kTextWhite = Colors.white;
const Color kGreenYes = Color(0xFF00C853);
const Color kRedNo = Color(0xFFD50000);

void main() => runApp(const MaterialApp(
  home: PolyFakeApp(),
  debugShowCheckedModeBanner: false,
  themeMode: ThemeMode.dark,
));

class PolyFakeApp extends StatefulWidget {
  const PolyFakeApp({super.key});
  @override
  State<PolyFakeApp> createState() => _PolyFakeAppState();
}

class _PolyFakeAppState extends State<PolyFakeApp> {
  int _currentIndex = 0;
  int coins = 1000;
  double _currentWager = 50;

  final PageController _pageController = PageController();

  String _userName = "Parieur Fou";
  String _userTag = "@parieur fou";
  String _userAvatar = "https://loremflickr.com/200/200/king";

  // --- VARIABLES POUR L'ANIMATION CENTRALE ---
  bool _showFeedback = false;
  bool _feedbackIsWin = false;
  int _feedbackAmount = 0;

  List<Map<String, dynamic>> history = [];
  late List<Map<String, dynamic>> availableParis;

  // --- LISTE COMPLÈTE ---
  final List<Map<String, dynamic>> _allParis = [
    {"id": "s1", "cat": "FOOT", "q": "Mbappé marque ce soir ?", "desc": "Ligue des Champions.", "img": "https://img.20mn.fr/jouCgA-2Tu6S7O7mDf9D-ik/1444x920_credit-obligatoire-photo-de-javier-borrego-afp7-shutterstock-16431423dz-kylian-mbappe-du-real-madrid-cf-en-action-lors-du-match-de-football-de-la-ligue-espagnole-la-liga-ea-sports-entre-le-villarreal-cf-et-le-real-madrid-au-stade-la-ceramica-le-24-janvier-2026-a-villarreal-en-espagne-villarreal-cf-v-real-madrid-la-liga-ea-sport-castellon-espagne-24-janvier-2026-shutterstock-editorial-villarreal-cf-v-real-madrid-l-16431423dz-2601242344", "chanceOui": 65, "stats": {"Forme": "Top", "Tirs": "5/match", "Moral": "Bon"}, "expert": "Il est intenable en ce moment.", "chart": [20, 50, 40, 80, 65]},
    {"id": "s2", "cat": "TENNIS", "q": "Djokovic prend sa retraite ?", "desc": "Fin de saison.", "img": "https://www.lequipe.fr/_medias/img-photo-jpg/novak-djokovic-ce-samedi-a-melbourne-p-lahalle-l-equipe/1500000002366966/0:0,2000:1333-828-552-75/3444c.jpg", "chanceOui": 15, "stats": {"Age": "37", "Titres": "24", "Physique": "Ok"}, "expert": "Il veut encore un Grand Chelem.", "chart": [10, 10, 12, 15, 15]},
    {"id": "s3", "cat": "BASKET", "q": "Wembanyama MVP ?", "desc": "NBA Saison 2026.", "img": "https://www.lequipe.fr/_medias/img-photo-jpg/victor-wembanyama-dans-la-nuit-de-lundi-a-mardi-eric-gay-ap/1500000002363227/689:65,1909:1285-828-828-75/7068e", "chanceOui": 40, "stats": {"Points": "30", "Contres": "5", "Hype": "Max"}, "expert": "Les stats sont là, mais l'équipe doit gagner.", "chart": [10, 20, 30, 35, 40]},
    {"id": "s4", "cat": "F1", "q": "Verstappen Champion ?", "desc": "GP de Monaco.", "img": "https://img.redbull.com/images/c_limit,w_1500,h_1000/f_auto,q_auto/redbullcom/2022/10/9/xiidcpp734qy5kgx64mb/max-verstappen-champion-monde-f1-japon-2022", "chanceOui": 85, "stats": {"Pole": "Oui", "Moteur": "Neuf", "Pluie": "Non"}, "expert": "La voiture est trop rapide pour les autres.", "chart": [70, 80, 82, 84, 85]},
    {"id": "s5", "cat": "RUGBY", "q": "La France gagne le tournoi ?", "desc": "6 Nations.", "img": "https://www.lequipe.fr/_medias/img-photo-jpg/damian-penaud-felicite-peato-mauvaka-lors-de-son-premier-essai-contre-les-all-blacks-samedi-p-la/1500000001572056/0:0,1998:1332-828-552-75/defeb.jpg", "chanceOui": 55, "stats": {"Groupe": "Soudé", "Dupont": "Là", "Domicile": "Oui"}, "expert": "Le crunch contre l'Angleterre sera décisif.", "chart": [40, 45, 50, 55, 55]},
    {"id": "f1", "cat": "CRYPTO", "q": "Bitcoin > 100k\$ ?", "desc": "Le cap symbolique.", "img": "https://www.cryptoninjas.net/wp-content/uploads/BTC-100000.png", "chanceOui": 42, "stats": {"RSI": "70", "Whales": "Achat", "News": "ETF"}, "expert": "Grosse résistance à 99k\$.", "chart": [30, 40, 60, 50, 42]},
    {"id": "f2", "cat": "BOURSE", "q": "Apple chute en bourse ?", "desc": "Ventes iPhone.", "img": "https://www.iphon.fr/app/uploads/2024/01/Apple-bourse-action-investissement-capitalisation-boursiere-par-iphon.fr_.jpg", "chanceOui": 20, "stats": {"Ventes": "-5%", "Services": "+10%", "Cash": "Infini"}, "expert": "Leur trésorerie les protège de tout.", "chart": [10, 15, 18, 22, 20]},
    {"id": "f3", "cat": "ÉCO", "q": "Le prix du café double ?", "desc": "Pénurie Brésil.", "img": "https://shouka-chamonix.fr/wp-content/uploads/2025/07/prix-cafe.webp", "chanceOui": 75, "stats": {"Récolte": "Mauvaise", "Stock": "Vide", "Demande": "Haute"}, "expert": "Faites des stocks, ça va piquer.", "chart": [20, 40, 60, 70, 75]},
    {"id": "f4", "cat": "IMMO", "q": "Loyer à Paris baisse ?", "desc": "Encadrement.", "img": "https://www.challenges.fr/_ipx/f_webp&enlarge_true&fit_cover&s_1360x840/cha/static/s3fs-public/2017-05/000-par197753.jpg%3FVersionId=qKmVHbIsCyuEb0tVOqw9d68cvpPDKcPM", "chanceOui": 10, "stats": {"Offre": "Rare", "Demande": "Explose", "JO": "Impact"}, "expert": "Même avec la loi, ça continue de monter.", "chart": [5, 5, 8, 9, 10]},
    {"id": "t1", "cat": "ESPACE", "q": "Premier pas sur Mars ?", "desc": "Avant 2030.", "img": "https://media.20min.ch/7/image/2023/12/27/4b68c797-f3e2-44f3-b8d0-ab7b8d218c74.jpeg?auto=format%2Ccompress%2Cenhance&fit=max&w=1200&h=1200&rect=0%2C0%2C1024%2C682&s=fb5006343f79a174b9ce625c972046be", "chanceOui": 25, "stats": {"Fusée": "Starship", "Test": "Crash", "Budget": "Enorme"}, "expert": "2035 semble plus réaliste.", "chart": [10, 15, 20, 30, 25]},
    {"id": "t2", "cat": "IA", "q": "L'IA devient consciente ?", "desc": "Skynet arrive ?", "img": "https://www.neozone.org/blog/wp-content/uploads/2025/08/science-conscience-intelligence-artificielle-evolution-001.jpg", "chanceOui": 5, "stats": {"Code": "Complexe", "Emotion": "Nulle", "Energie": "Max"}, "expert": "C'est juste des maths, pas une âme.", "chart": [1, 2, 3, 4, 5]},
    {"id": "t3", "cat": "GAMING", "q": "GTA 6 sort cette année ?", "desc": "L'attente infinie.", "img": "https://wp-pa.phonandroid.com/uploads/2023/12/GTA-6-1-1.jpg", "chanceOui": 30, "stats": {"Trailer": "Sorti", "Dev": "Lent", "Bug": "Fix"}, "expert": "Rockstar vise Noël prochain.", "chart": [80, 60, 40, 30, 30]},
    {"id": "t4", "cat": "TECH", "q": "TikTok interdit ?", "desc": "Loi USA/EU.", "img": "https://www.ifri.org/sites/default/files/migrated_files/images/thumbnails/image/shutterstock_2265047307.jpg", "chanceOui": 50, "stats": {"Politique": "Tendue", "Data": "Chine", "Lobby": "Fort"}, "expert": "Ça dépendra des élections.", "chart": [10, 30, 50, 45, 50]},
    {"id": "m1", "cat": "MÉTÉO", "q": "Neige à Noël ?", "desc": "Paris centre.", "img": "https://www.frequence-sud.fr/img/pict/max/7699.jpg", "chanceOui": 12, "stats": {"Temp": "+8°C", "Nuage": "Gris", "Vent": "Ouest"}, "expert": "Le réchauffement rend ça rare.", "chart": [30, 20, 15, 10, 12]},
    {"id": "m2", "cat": "CLIMAT", "q": "Eté caniculaire ?", "desc": "+45°C prévu.", "img": "https://www.ville-vezinlecoquet.fr/medias/2020/11/grand-froid-canicule.jpg", "chanceOui": 90, "stats": {"ElNino": "Actif", "CO2": "Record", "Eau": "Manque"}, "expert": "Préparez la clim.", "chart": [60, 70, 80, 85, 90]},
    {"id": "m3", "cat": "NATURE", "q": "Volcan se réveille ?", "desc": "Islande.", "img": "https://www.parismatch.com/lmnr/var/pm/public/media/image/2022/03/01/00/Le-volcan-Merapi-se-reveille-en-Indonesie.jpg?VersionId=HiWGsPFm0w4LOzB6qjrcXXsSMjMV3uoq", "chanceOui": 80, "stats": {"Séisme": "Oui", "Fumée": "Oui", "Lave": "Proche"}, "expert": "Éruption imminente.", "chart": [10, 30, 50, 90, 80]},
    {"id": "p1", "cat": "PEOPLE", "q": "Rihanna : Nouvel album ?", "desc": "Depuis 2016...", "img": "https://numero.com/wp-content/uploads/2025/02/rihanna-album-2.jpg", "chanceOui": 35, "stats": {"Studio": "Non", "Maquillage": "Oui", "Bébé": "Oui"}, "expert": "Elle est retraitée de la musique.", "chart": [50, 40, 30, 35, 35]},
    {"id": "p2", "cat": "CINÉMA", "q": "Avatar 3 bat des records ?", "desc": "Box Office.", "img": "https://fr.web.img6.acsta.net/img/52/fb/52fb8f0345af2b0940557aa049ca19fd.jpg", "chanceOui": 95, "stats": {"Hype": "Mondiale", "3D": "Révolution", "Prix": "Cher"}, "expert": "Cameron ne rate jamais son coup.", "chart": [80, 85, 90, 92, 95]},
    {"id": "p3", "cat": "FUN", "q": "Les aliens débarquent ?", "desc": "Ovni confirmé.", "img": "https://i.etsystatic.com/52951330/r/isla/04b571/72664024/isla_500x500.72664024_oehcepwk.jpg", "chanceOui": 1, "stats": {"Preuve": "Floue", "NASA": "Silence", "Film": "Fiction"}, "expert": "On est seuls... pour l'instant.", "chart": [1, 1, 2, 1, 1]},
    {"id": "p4", "cat": "FOOD", "q": "La baguette à 2€ ?", "desc": "Inflation blé.", "img": "https://assets.tmecosys.com/image/upload/t_web_rdp_recipe_584x480_1_5x/img/recipe/ras/Assets/855e1eeb9373f26f7b080d53a24725aa/Derivates/88c04dbf31c66f22977e11bea46c8f4cc259a086.jpg", "chanceOui": 60, "stats": {"Énergie": "Chère", "Farine": "Hausse", "Boulanger": "Triste"}, "expert": "Ça va arriver plus vite qu'on croit.", "chart": [10, 20, 40, 50, 60]},
    {"id": "me1", "cat": "PROJET", "q": "20/20 pour ce projet ?", "desc": "Le code est propre.", "img": "https://img.freepik.com/photos-gratuite/ordinateur-portable-table-bois_53876-20635.jpg?semt=ais_user_personalization&w=740&q=80", "chanceOui": 99, "stats": {"Bug": "0", "UI": "Slick", "Prof": "Séduit"}, "expert": "C'est quand même super bien faigt.", "chart": [90, 95, 98, 99, 99]},
  ];

  @override
  void initState() {
    super.initState();
    availableParis = List.from(_allParis)..shuffle();

    // --- CORRECTION DU DÉMARRAGE ARDUINO ---
    // On attend 500ms que l'app se lance bien, puis on force l'envoi de 1000
    Future.delayed(const Duration(milliseconds: 500), () {
      _sendToArduino(coins);
    });
  }

  void _sendToArduino(int value) async {
    try {
      final socket = await Socket.connect(PC_IP, 4545, timeout: const Duration(milliseconds: 500));
      socket.write('$value');
      await socket.flush();
      socket.close();
      print("✅ ENVOYÉ À $PC_IP");
    } catch (e) {
      print("⚠️ ERREUR CONNEXION : $e");
    }
  }

  double getOdd(int percentage) => percentage <= 0 ? 99.0 : (percentage >= 100 ? 1.01 : double.parse((100 / percentage).toStringAsFixed(2)));

  // --- LOGIQUE DE JEU AVEC ANIMATION CENTRALE ---
  void _processBet(int index, bool isOui) {
    HapticFeedback.mediumImpact();
    var currentPari = availableParis[index];
    int chanceOui = (currentPari['chanceOui'] as num).toInt();

    bool resultatReelEstOui = Random().nextInt(100) < chanceOui;
    bool isWin = (isOui && resultatReelEstOui) || (!isOui && !resultatReelEstOui);

    int mise = _currentWager.round();
    double coteJouee = isOui ? getOdd(chanceOui) : getOdd(100 - chanceOui);
    int gainTotal = (mise * coteJouee).round();
    int profitNet = gainTotal - mise;

    setState(() {
      if (isWin) coins += profitNet; else coins -= mise;

      history.insert(0, {
        "q": currentPari['q'],
        "choix": isOui ? "OUI (x$coteJouee)" : "NON (x$coteJouee)",
        "resultat": isWin ? "GAGNÉ" : "PERDU",
        "gain": isWin ? "+$profitNet" : "-$mise",
        "img": currentPari['img']
      });
      availableParis.removeAt(index);

      // --- DÉCLENCHEMENT DE L'ANIMATION CENTRALE ---
      _feedbackIsWin = isWin;
      _feedbackAmount = isWin ? profitNet : mise;
      _showFeedback = true;
    });

    // CACHER L'ANIMATION APRÈS 1 SECONDE
    Timer(const Duration(milliseconds: 1000), () {
      if(mounted) setState(() => _showFeedback = false);
    });

    _sendToArduino(coins);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: kPrimaryBlue,
        scaffoldBackgroundColor: kBackgroundDark,
        appBarTheme: const AppBarTheme(backgroundColor: kCardDark, elevation: 0),
      ),
      child: Scaffold(
        body: [
          _buildHomePage(),
          _buildHistoryPage(),
          _buildProfilePage()
        ][_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: kCardDark,
          selectedItemColor: Colors.yellowAccent,
          unselectedItemColor: Colors.white54,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.style), label: "Paris"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "Historique"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
          ],
        ),
      ),
    );
  }

  // --- PAGE D'ACCUEIL : LE MIX PARFAIT AVEC ANIMATION CENTRALE ---
  Widget _buildHomePage() {
    return Column(
      children: [
        AppBar(title: Text("Solde : $coins 🪙", style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold))),

        Expanded(
          child: Stack(
            children: [
              // 1. LE SWIPE
              availableParis.isEmpty
                  ? Center(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.yellowAccent, foregroundColor: Colors.black),
                  onPressed: () => setState(() => availableParis = List.from(_allParis)..shuffle()),
                  icon: const Icon(Icons.refresh), label: const Text("Nouvelle fournée")))
                  : PageView.builder(
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                controller: _pageController,
                itemCount: availableParis.length,
                itemBuilder: (context, index) {
                  final pari = availableParis[index];
                  return Center(
                    child: TinderCard(
                      key: ValueKey(pari['id']),
                      onSwipe: (isOui) {
                        _processBet(index, isOui);
                      },
                      child: _buildBetCardUI(pari),
                    ),
                  );
                },
              ),

              // 2. L'ANIMATION DE RÉSULTAT (OVERLAY)
              IgnorePointer(
                ignoring: !_showFeedback, // Laisse passer les clics quand invisible
                child: AnimatedOpacity(
                  opacity: _showFeedback ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black54, // Fond semi-transparent
                    child: Center(
                      child: Transform.scale(
                        scale: _showFeedback ? 1.0 : 0.5, // Effet de pop
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                              color: kCardDark,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: _feedbackIsWin ? kGreenYes : kRedNo, width: 3),
                              boxShadow: [BoxShadow(color: (_feedbackIsWin ? kGreenYes : kRedNo).withOpacity(0.5), blurRadius: 30)]
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  _feedbackIsWin ? Icons.emoji_events : Icons.cancel,
                                  size: 80,
                                  color: _feedbackIsWin ? kGreenYes : kRedNo
                              ),
                              const SizedBox(height: 15),
                              Text(
                                  _feedbackIsWin ? "VICTOIRE !" : "PERDU...",
                                  style: TextStyle(
                                      color: _feedbackIsWin ? kGreenYes : kRedNo,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900
                                  )
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  _feedbackIsWin ? "+$_feedbackAmount" : "-$_feedbackAmount",
                                  style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Zone de mise
        Container(
          padding: const EdgeInsets.all(15),
          color: kCardDark,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("MISE PAR SWIPE", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("${_currentWager.round()} Coins", style: const TextStyle(color: Colors.yellowAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _currentWager,
                min: 10, max: 500, divisions: 49,
                activeColor: Colors.yellowAccent, inactiveColor: Colors.grey[700],
                label: _currentWager.round().toString(),
                onChanged: (v) => setState(() => _currentWager = v),
              ),
            ],
          ),
        )
      ],
    );
  }

  // --- DESIGN DE LA CARTE ---
  Widget _buildBetCardUI(Map<String, dynamic> pari) {
    int chance = (pari['chanceOui'] as num).toInt();
    double coteOui = getOdd(chance);
    double coteNon = getOdd(100 - chance);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20)]),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(pari['img'], fit: BoxFit.cover, errorBuilder: (c,e,s)=>Container(color: Colors.grey[800], child: const Icon(Icons.broken_image, color: Colors.white))),
                ),
                Positioned(top: 10, right: 10, child: IconButton(icon: const Icon(Icons.info, color: Colors.white, size: 30), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => BetDetailScreen(pari: pari, coteOui: coteOui, coteNon: coteNon))))),
                Positioned(top: 15, left: 15, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: kPrimaryBlue, borderRadius: BorderRadius.circular(5)), child: Text(pari['cat'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(pari['q'], textAlign: TextAlign.center, style: const TextStyle(color: kTextWhite, fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(pari['desc'], style: const TextStyle(color: Colors.white54)),
                  const Divider(color: Colors.white24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _bubble(chance, coteOui, true),
                    const Text("VS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    _bubble(100-chance, coteNon, false),
                  ])
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _bubble(int pct, double cote, bool isOui) => Column(children: [
    CircleAvatar(radius: 30, backgroundColor: isOui ? kGreenYes : kRedNo, child: Text("$pct%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
    const SizedBox(height: 5),
    Text(isOui ? "OUI x$cote" : "NON x$cote", style: TextStyle(color: isOui ? kGreenYes : kRedNo, fontWeight: FontWeight.bold))
  ]);

  // --- PAGES SECONDAIRES ---
  Widget _buildHistoryPage() {
    return DefaultTabController(length: 2, child: Scaffold(appBar: AppBar(title: const Text("Historique"), bottom: const TabBar(indicatorColor: Colors.yellowAccent, labelColor: Colors.yellowAccent, tabs: [Tab(text: "GAGNÉS"), Tab(text: "PERDUS")])), body: TabBarView(children: [_buildList(history.where((e) => e['resultat'] == "GAGNÉ").toList()), _buildList(history.where((e) => e['resultat'] == "PERDU").toList())])));
  }

  Widget _buildList(List<Map<String, dynamic>> items) {
    if (items.isEmpty) return const Center(child: Text("Le néant...", style: TextStyle(color: Colors.grey)));
    return ListView.builder(itemCount: items.length, itemBuilder: (c, i) => Card(color: kCardDark, margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: ListTile(leading: CircleAvatar(backgroundImage: NetworkImage(items[i]['img'])), title: Text(items[i]['q']), subtitle: Text(items[i]['resultat'], style: TextStyle(color: items[i]['resultat'] == "GAGNÉ" ? kGreenYes : kRedNo)), trailing: Text(items[i]['gain'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))));
  }

  Widget _buildProfilePage() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CircleAvatar(radius: 60, backgroundImage: NetworkImage(_userAvatar)),
      const SizedBox(height: 20),
      Text(_userName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      Text(_userTag, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 40),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [_statItem("$coins", "Coins", Colors.yellowAccent), const SizedBox(width: 30), _statItem("${history.length}", "Paris", kPrimaryBlue), const SizedBox(width: 30), _statItem("${history.where((e)=>e['resultat']=='GAGNÉ').length}", "Victoires", kGreenYes)]),
      const SizedBox(height: 40),
      ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white), onPressed: () { setState(() { coins = 1000; history.clear(); availableParis = List.from(_allParis)..shuffle(); }); _sendToArduino(1000); }, icon: const Icon(Icons.restart_alt), label: const Text("RESET TOTAL"))
    ]));
  }

  Widget _statItem(String val, String label, Color color) => Column(children: [Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white70))]);
}

// ==========================================================
// 👑 LA CLASSE TINDER CARD (ANIMATION FLUIDE)
// ==========================================================
class TinderCard extends StatefulWidget {
  final Widget child;
  final Function(bool isOui) onSwipe;

  const TinderCard({super.key, required this.child, required this.onSwipe});

  @override
  State<TinderCard> createState() => _TinderCardState();
}

class _TinderCardState extends State<TinderCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _dragOffset = Offset.zero;
  double _angle = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _controller.addListener(() {
      setState(() {
        _dragOffset = Offset.lerp(_dragOffset, Offset.zero, _controller.value)!;
        _angle = _dragOffset.dx / 1000;
      });
    });
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += Offset(details.delta.dx, 0);
      _angle = (_dragOffset.dx / MediaQuery.of(context).size.width) * 0.3;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _isDragging = false;
    double screenWidth = MediaQuery.of(context).size.width;
    double threshold = screenWidth * 0.35;

    if (_dragOffset.dx.abs() > threshold) {
      bool isOui = _dragOffset.dx > 0;
      widget.onSwipe(isOui);
    } else {
      _controller.forward(from: 0).then((_) {
        setState(() { _dragOffset = Offset.zero; _angle = 0; });
        _controller.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        onHorizontalDragEnd: _onHorizontalDragEnd,

        child: Transform.translate(
          offset: _dragOffset,
          child: Transform.rotate(
            angle: _angle,
            child: Stack(
              children: [
                widget.child,
                if (_isDragging)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _dragOffset.dx > 0
                            ? kGreenYes.withOpacity((_dragOffset.dx / 500).clamp(0.0, 0.5))
                            : kRedNo.withOpacity((-_dragOffset.dx / 500).clamp(0.0, 0.5)),
                      ),
                      child: Center(
                        child: _dragOffset.dx.abs() > 50
                            ? Icon(_dragOffset.dx > 0 ? Icons.thumb_up : Icons.thumb_down, size: 100, color: Colors.white.withOpacity(0.8))
                            : null,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}

// --- PAGE DÉTAILS ---
class BetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pari;
  final double coteOui;
  final double coteNon;
  const BetDetailScreen({super.key, required this.pari, required this.coteOui, required this.coteNon});

  @override
  Widget build(BuildContext context) {
    final stats = pari['stats'] as Map<String, dynamic>? ?? {};
    final chartData = pari['chart'] as List<int>? ?? [10, 20, 30, 20, 10];

    return Scaffold(
      backgroundColor: kBackgroundDark,
      appBar: AppBar(backgroundColor: Colors.transparent, title: Text(pari['cat'], style: const TextStyle(color: Colors.yellowAccent))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200, decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: NetworkImage(pari['img']), fit: BoxFit.cover)),
              child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
            ),
            const SizedBox(height: 20),
            Text(pari['q'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blueAccent)), child: Row(children: [const Icon(Icons.psychology, color: Colors.blueAccent), const SizedBox(width: 10), Expanded(child: Text(pari['expert'] ?? "...", style: const TextStyle(color: Colors.white)))])),
            const SizedBox(height: 30),
            const Text("TENDANCE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(height: 100, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: chartData.map((v) => Container(width: 40, height: v.toDouble(), color: v > 50 ? kGreenYes : kRedNo)).toList())),
            const SizedBox(height: 30),
            const Text("STATS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(spacing: 10, runSpacing: 10, children: stats.entries.map((e) => Chip(backgroundColor: kCardDark, label: Text("${e.key}: ${e.value}", style: const TextStyle(color: Colors.white)))).toList()),
            const SizedBox(height: 30),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.yellowAccent, foregroundColor: Colors.black, padding: const EdgeInsets.all(15)), onPressed: () => Navigator.pop(context), child: const Text("RETOURNER PARIER")))
          ],
        ),
      ),
    );
  }
}