import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ignite/models/profile/pubg.dart';
import 'package:ignite/pages/dashboard_page.dart';
import 'package:ignite/provider/auth_provider.dart';
import 'package:ignite/provider/page_provider.dart';
import 'package:ignite/provider/profile/pubg_profile_provider.dart';
import 'package:provider/provider.dart';

class PUBGProfilePage extends StatefulWidget {
  PUBGProfilePage({Key? key}) : super(key: key);

  @override
  _PUBGProfilePageState createState() => _PUBGProfilePageState();
}

class _PUBGProfilePageState extends State<PUBGProfilePage>
    with SingleTickerProviderStateMixin {
  late AuthProvider _authProvider;
  late PUBGProfileProvider _pubgProfileProvider;

  final firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;
  late Animation<double> _animation;

  late TextEditingController _textController;
  late FocusNode _textFocusNode;
  late FocusNode _dropFocusNode;
  bool _isEditingText = false;

  bool _searching = false;

  final Map<String, String> _items = {'Steam': 'steam', 'Kakao': 'kakao'};
  String _selectedItem = 'steam';

  String? _validateText(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Username can\'t be empty';
    }
    return null;
  }

  _addUserDialog(PUBGUser pubgUser) async {
    await firestore
        .collection('user')
        .doc(_authProvider.currentUser!.uid)
        .collection('accounts')
        .doc('pubg')
        .set({
      'server': _selectedItem,
      'accountId': pubgUser.accountId,
      'name': pubgUser.name,
      'profileImage': pubgUser.profileImage,
      'soloTier': pubgUser.soloTier,
      'soloRank': pubgUser.soloRank,
      'soloPoints': pubgUser.soloPoints,
      'squadTier': pubgUser.squadTier,
      'squadRank': pubgUser.squadRank,
      'squadPoints': pubgUser.squadPoints,
    }).then((value) async {
      Navigator.pop(context);
      await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('?????? ??????!'),
              content: Text('?????? ????????? ????????? ?????????????????????\n???????????? ????????? \'??? ??????\'?????? ???????????????'),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(),
                        ),
                        (route) => false);
                    Provider.of<PageProvider>(context, listen: false)
                        .updatePage(1);
                  },
                  child: Text('??????'),
                ),
              ],
            );
          });
    });
    Navigator.pop(context);
  }

  _addUserData(PUBGUser pubgUser) async {
    await firestore
        .collection('user')
        .doc(_authProvider.currentUser!.uid)
        .collection('accounts')
        .doc('pubg')
        .get()
        .then((value) async {
      if (value.exists) {
        Navigator.pop(context);
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('???????'),
                content: Text('?????? ?????? ????????? ???????????? ????????????\n\'???\'??? ????????? ?????? ????????? ??????????????????'),
                actions: [
                  MaterialButton(
                    onPressed: () async {
                      _addUserDialog(pubgUser);
                    },
                    child: Text('???'),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('?????????'),
                  ),
                ],
              );
            });
      } else {
        _addUserDialog(pubgUser);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _animation.addListener(() => setState(() {}));

    _textController = TextEditingController();
    _textController.text = '';
    _textFocusNode = FocusNode();
    _dropFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _pubgProfileProvider =
        Provider.of<PUBGProfileProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PUBG'),
            Text(
              'Playerunknown\'s Battlegrounds',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
      body: _bodyContainer(),
    );
  }

  Widget _bodyContainer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DropdownButton(
            autofocus: true,
            focusNode: _dropFocusNode,
            value: _selectedItem,
            items: _items
                .map(
                  (key, value) {
                    return MapEntry(
                      key,
                      DropdownMenuItem<String>(
                        value: value,
                        child: Text(key),
                      ),
                    );
                  },
                )
                .values
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedItem = value.toString();
              });
              _dropFocusNode.unfocus();
              FocusScope.of(context).requestFocus(_textFocusNode);
            },
            hint: Text('??????'),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: new Border(
                bottom: new BorderSide(color: Colors.redAccent),
              ),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                fillColor: Colors.redAccent,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                labelText: 'Username',
                icon: Icon(Icons.person),
                border: InputBorder.none,
                errorText:
                    _isEditingText ? _validateText(_textController.text) : null,
                errorStyle: TextStyle(
                  fontSize: 12,
                  color: Colors.redAccent,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {
                    if (_validateText(_textController.text) == null) {
                      setState(() {
                        _searching = true;
                      });
                      await _pubgProfileProvider.loadUserProfile(
                          _textController.text, _selectedItem);
                      setState(() {
                        _searching = false;
                        _animationController.reset();
                      });
                      _animationController.forward();
                    }
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _isEditingText = true;
                });
              },
              onSubmitted: (value) async {
                if (_validateText(_textController.text) == null) {
                  setState(() {
                    _searching = true;
                  });
                  await _pubgProfileProvider.loadUserProfile(
                      _textController.text, _selectedItem);
                  setState(() {
                    _searching = false;
                    _animationController.reset();
                  });
                  _animationController.forward();
                }
              },
            ),
          ),
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: _animation,
            child: AnimatedOpacity(
              opacity: _searching ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInQuint,
              child: Container(
                alignment: Alignment.center,
                height: _searching
                    ? 0.0
                    : MediaQuery.of(context).size.height * 0.65 -
                        MediaQuery.of(context).viewInsets.bottom,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: _pubgProfileProvider.pubgUser != null
                    ? _userCard(_pubgProfileProvider.pubgUser!)
                    : Text('?????? ????????? ????????????'),
              ),
            ),
          ),
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: _animation,
            child: AnimatedOpacity(
              opacity: _searching ? 0.0 : 1.0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInQuint,
              child: MaterialButton(
                elevation: 0.0,
                minWidth: double.maxFinite,
                height: 50.0,
                onPressed: _pubgProfileProvider.pubgUser != null
                    ? () async {
                        await _confirmAccountDialog(
                            _pubgProfileProvider.pubgUser!);
                      }
                    : null,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                color: _pubgProfileProvider.pubgUser != null
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: _pubgProfileProvider.pubgUser != null
                        ? Colors.white
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _userCard(PUBGUser pubgUser) {
    return Card(
      child: ListTile(
        leading: pubgUser.profileImage != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(pubgUser.profileImage!),
              )
            : CircleAvatar(),
        title:
            Text(pubgUser.name!, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: BoxDecoration(
                  gradient: _pubgTierColors(pubgUser.squadTier),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                    ),
                  ]),
              child: pubgUser.squadTier != null
                  ? Text(
                      '${pubgUser.squadTier} ${pubgUser.squadRank}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    )
                  : Text(
                      'UNRANKED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _confirmAccountDialog(PUBGUser pubgUser) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('??? ????????? ??????????'),
            content: _userCard(pubgUser),
            actions: [
              MaterialButton(
                onPressed: () async {
                  await _addUserData(pubgUser);
                },
                child: Text('???'),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('?????????'),
              ),
            ],
          );
        });
  }

  LinearGradient? _pubgTierColors(String? tier) {
    switch (tier) {
      case 'Bronze':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4F1C0D),
            Color(0xFFA96A40),
          ],
        );
      case 'Silver':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF848482),
            Color(0xFFB0C4DE),
          ],
        );
      case 'Gold':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFDA9100),
            Color(0xFFFCC201),
          ],
        );
      case 'Platinum':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF209BBA),
            Color(0xFFA8D8DF),
          ],
        );
      case 'Diamond':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF4467C4),
            Color(0xFF8EC3E6),
          ],
        );
      case 'Master':
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF7BC1FA),
            Color(0xFFFCC201),
          ],
        );
      case null:
        return const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF104730),
            Color(0xFF6D9775),
          ],
        );
    }
  }
}
