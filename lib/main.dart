import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:http/http.dart' as http;

// TODO: firebase 통신 간, loading dialog 필요함

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCpY1waE7Z1C9wHHnNeTFoXcPUON4tKDTE",
      authDomain: "course4-microproject-test.firebaseapp.com",
      projectId: "course4-microproject-test",
      storageBucket: "course4-microproject-test.appspot.com",
      messagingSenderId: "4648850754",
      appId: "1:4648850754:web:a32ea18dfa3ea566fce4db",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(
            create: (context) => BottomNavigationBarProvider()),
        ChangeNotifierProvider(create: (context) => PostingProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/sign_in',
        routes: {
          '/sign_in': (context) => SignInScreen(),
          '/sign_up': (context) => SignUpScreen(),
          '/email_verification': (context) => EmailVerificationScreen(),
          '/password_reset': (context) => PasswordResetScreen(),
          '/all_postings': (context) => AllPostingsScreen(),
          '/new_postings': (context) => NewPostingsScreen(),
          '/hot_postings': (context) => HotPostingsScreen(),
          '/bookmark_postings': (context) => MyBookmarkPostingsScreen(),
          '/like_postings': (context) => MyLikePostingsScreen(),
          '/my_postings': (context) => MyPostingsScreen(),
          '/other_postings': (context) => OtherPostingsScreen(),
          '/my_account': (context) => MyAccountScreen(),
          '/add_posting': (context) => AddPostingScreen(),
          '/update_posting': (context) => UpdatePostingScreen(),
          '/album': (context) => AlbumScreen(),
          '/posting': (context) => OnePostingScreen(),
          '/comment': (context) => CommentScreen(),
        },
      ),
    );
  }
}

/// 회원가입, 로그인, 이메일 인증, 비밀번호 재설정 start

/// 로그인 페이지
class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthHelper _authHelper = AuthHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(),
            SizedBox(height: 34),
            SignInTextField(
              controller: _emailController,
              hintText: '이메일',
            ),
            SizedBox(height: 10),
            SignInTextField(
              controller: _passwordController,
              obscureText: true,
              hintText: '비밀번호',
            ),
            SizedBox(height: 21),
            SignInElevatedButton(
              onPressed: () async {
                final res = await _authHelper.signInEmailAndPassword(
                  context,
                  _emailController.text,
                  _passwordController.text,
                );
                if (res) {
                  Navigator.pushNamed(context, '/all_postings');
                }
              },
              buttonName: '로그인',
            ),
            SizedBox(height: 21),
            SignInTextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/password_reset');
              },
              buttonName: '비밀번호를 잊으셨나요?',
              color: Color(0xFF113767),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '계정이 없으신가요? ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SignInTextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/sign_up');
                  },
                  buttonName: '가입하기',
                  color: Color(0xFF3C95EF),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// 회원가입 페이지
class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthHelper _authHelper = AuthHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(),
            SizedBox(height: 34),
            SignInTextField(
              controller: _emailController,
              hintText: '이메일',
            ),
            SizedBox(height: 13),
            SignInTextField(
              controller: _passwordController,
              obscureText: true,
              hintText: '비밀번호',
            ),
            SizedBox(height: 34),
            SignInElevatedButton(
              onPressed: () async {
                final res = await _authHelper.signUpEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );
                if (res != null) {
                  _authHelper.sendEmailVerification();
                  Navigator.pushNamed(
                    context,
                    '/email_verification',
                    arguments: _emailController.text,
                  );
                }
              },
              buttonName: '가입',
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '계정이 있으신가요? ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SignInTextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  buttonName: '로그인',
                  color: Color(0xFF3C95EF),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// 이메일 인증 페이지
class EmailVerificationScreen extends StatelessWidget {
  EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(),
            SizedBox(height: 31),
            infoMessage(email),
            SizedBox(height: 29),
            SignInElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/sign_in', (route) => false);
              },
              buttonName: '로그인 화면으로 이동',
            ),
          ],
        ),
      ),
    );
  }

  Widget infoMessage(String email) {
    return Container(
      width: 309,
      height: 94,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDBDBDB)),
        borderRadius: BorderRadius.circular(3),
        color: Color(0xFFFAFAFA),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '회원가입 완료를 위해 ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              Text(
                '이메일 인증',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                '을 진행합니다.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              )
            ],
          ),
          Text(
            '$email으로 보내드린\n인증메일을 확인해주세요',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

/// 비밀번호 재설정 페이지
class PasswordResetScreen extends StatelessWidget {
  PasswordResetScreen({super.key});

  final TextEditingController _emailController = TextEditingController();

  final AuthHelper _authHelper = AuthHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(),
            SizedBox(height: 37),
            infoMessage(),
            SizedBox(height: 11),
            SignInTextField(controller: _emailController, hintText: '이메일'),
            SizedBox(height: 19),
            SignInElevatedButton(
              onPressed: () {
                _authHelper.sendPasswordResetEmail(_emailController.text);
                // TODO: 버튼 누른 후 동작 필요함
              },
              buttonName: '비밀번호 재설정하기',
            ),
            // TODO: 삭제 필요함
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('뒤로가기'),
            )
          ],
        ),
      ),
    );
  }

  Widget infoMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '가입했던 이메일을 입력해주세요.',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '비밀번호 재설정 메일',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              '을 보내드립니다.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ],
    );
  }
}

// TODO: class명 수정
class SignInTextField extends StatelessWidget {
  const SignInTextField({
    super.key,
    required this.controller,
    this.obscureText = false,
    required this.hintText,
  });

  final TextEditingController controller;
  final bool obscureText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 268,
      height: 38,
      child: TextField(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF737373),
        ),
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFDBDBDB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFDBDBDB)),
          ),
          filled: true,
          fillColor: Color(0xFFFAFAFA),
          hoverColor: Colors.transparent,
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF737373),
          ),
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }
}

// TODO: class명 수정
class SignInElevatedButton extends StatelessWidget {
  const SignInElevatedButton({
    super.key,
    required this.onPressed,
    required this.buttonName,
  });

  final Function() onPressed;
  final String buttonName;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 268,
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          buttonName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// TODO: class명 수정
class SignInTextButton extends StatelessWidget {
  const SignInTextButton({
    super.key,
    required this.onPressed,
    required this.buttonName,
    required this.color,
  });

  final Function() onPressed;
  final String buttonName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(
        buttonName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}

// TODO: class명 수정
class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2FMicrogram_logo.png?alt=media&token=bb3f7b8b-9275-47cf-9c30-22fee3069465',
      width: 174,
      height: 50,
    );
  }
}

/// 회원가입, 로그인, 이메일 인증, 비밀번호 재설정 end

/// 전체 게시물, 인기 게시물, 최신 게시물, 게시물 상세 start

class AllPostingsScreen extends StatefulWidget {
  AllPostingsScreen({super.key});

  @override
  State<AllPostingsScreen> createState() => _AllPostingsScreenState();
}

class _AllPostingsScreenState extends State<AllPostingsScreen> {
  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        title: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2FMicrogram_logo.png?alt=media&token=bb3f7b8b-9275-47cf-9c30-22fee3069465',
          width: 118,
          height: 34,
        ),
        actions: [
          PopupMenu(
            items: [
              PopupMenuModel(
                title: '최근 게시물',
                onTap: () => Navigator.pushNamed(context, '/new_postings'),
              ),
              PopupMenuModel(
                title: '인기 게시물',
                onTap: () => Navigator.pushNamed(context, '/hot_postings'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: _cloudFirestoreHelper.getAllPostings(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Container();
          }
          final postings = snapshot.data!.docs
              .map((e) => PostModel.fromMap(e.data()))
              .toList();
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: postings.length,
              itemBuilder: (_, index) {
                return Posting(postId: postings[index].postId);
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}

class NewPostingsScreen extends StatelessWidget {
  NewPostingsScreen({super.key});
  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '최신 게시물',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
        ),
      ),
      body: FutureBuilder(
        future: _cloudFirestoreHelper.getNewPostings(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Container();
          }
          final postings = snapshot.data!.docs
              .map((e) => PostModel.fromMap(e.data()))
              .toList();
          return ListView.builder(
            shrinkWrap: true,
            itemCount: postings.length,
            itemBuilder: (_, index) {
              return Posting(postId: postings[index].postId);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}

class HotPostingsScreen extends StatelessWidget {
  HotPostingsScreen({super.key});

  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '인기 게시물',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
        ),
      ),
      body: FutureBuilder(
        future: _cloudFirestoreHelper.getHotPostings(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Container();
          }
          final postings = snapshot.data!.docs
              .map((e) => PostModel.fromMap(e.data()))
              .toList();
          return ListView.builder(
            shrinkWrap: true,
            itemCount: postings.length,
            itemBuilder: (_, index) {
              return Posting(postId: postings[index].postId);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}

/// 포스팅 1개용 화면
class OnePostingScreen extends StatelessWidget {
  OnePostingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final postId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          '게시물',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
      ),
      body: Posting(postId: postId),
    );
  }
}

/// 포스팅 내용 -> 1개, 여러개 동시에 호환하기 위해 class로 분리
class Posting extends StatefulWidget {
  Posting({
    super.key,
    required this.postId,
  });

  final String postId;

  @override
  State<Posting> createState() => _PostingState();
}

class _PostingState extends State<Posting> {
  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _cloudFirestoreHelper.getOnePosting(widget.postId),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        final post =
            PostModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
        return SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              if (ModalRoute.of(context)!.settings.name! == '/posting') return;
              Navigator.pushNamed(context, '/posting', arguments: post.postId);
            },
            child: Column(
              children: [
                SizedBox(height: 20),
                profileSection(context, post),
                SizedBox(height: 20),
                imageSection(post.postImg),
                contentSection(context, post),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget profileSection(BuildContext context, PostModel model) {
    return FutureBuilder(
      future: _cloudFirestoreHelper.getOneUser(model.userId),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        final user =
            UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
        return GestureDetector(
          onTap: () {
            if (Provider.of<AuthProvider>(context, listen: false)
                    .myAccount!
                    .userId ==
                user.userId) {
              Navigator.pushNamed(context, '/my_postings');
            } else {
              Navigator.pushNamed(context, '/other_postings', arguments: user);
            }
          },
          child: Row(
            children: [
              SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  user.profileImg ?? '',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD9D9D9),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 10),
              Text(
                user.name ?? user.email,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              ),
              Spacer(),
              Provider.of<AuthProvider>(context, listen: false)
                          .myAccount!
                          .userId ==
                      user.userId
                  ? PopupMenu(
                      items: [
                        PopupMenuModel(
                          title: '수정하기',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/update_posting',
                              arguments: model,
                            );
                          },
                        ),
                        PopupMenuModel(
                          title: '삭제하기',
                          onTap: () {
                            _cloudFirestoreHelper.deletePosting(
                                context, widget.postId);
                          },
                        ),
                      ],
                      icon: Icons.more_horiz_outlined,
                    )
                  : SizedBox(),
              SizedBox(width: 16),
            ],
          ),
        );
      },
    );
  }

  Widget imageSection(String url) {
    return Image.network(
      url,
      width: 375,
      height: 340,
      fit: BoxFit.cover,
    );
  }

  Widget contentSection(BuildContext context, PostModel model) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<AuthProvider>(
            builder: (_, provider, __) {
              final myAccount = provider.myAccount!;
              return Row(
                children: [
                  buttons(
                    onTap: () async {
                      model = await _cloudFirestoreHelper.likePosting(
                        context,
                        model,
                      );
                      setState(() {});
                    },
                    icon: myAccount.likeList.contains(model.postId)
                        ? Icons.favorite_outlined
                        : Icons.favorite_border_outlined,
                  ),
                  SizedBox(width: 12),
                  buttons(
                    onTap: () {
                      Navigator.pushNamed(context, '/comment',
                          arguments: model);
                    },
                    icon: Icons.mode_comment_outlined,
                  ),
                  Spacer(),
                  buttons(
                    onTap: () {
                      _cloudFirestoreHelper.bookmarkPosting(
                        context,
                        model.postId,
                      );
                    },
                    icon: myAccount.bookmarkList.contains(model.postId)
                        ? Icons.bookmark
                        : Icons.bookmark_outline,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
                text: '${model.likeNum} ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF262626),
                ),
                children: [
                  TextSpan(
                    text: '${model.likeNum == 1 ? 'like' : 'likes'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF262626),
                    ),
                  ),
                ]),
          ),
          SizedBox(height: 8),
          FutureBuilder(
            future: _cloudFirestoreHelper.getOneUser(model.userId),
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              final user = UserModel.fromMap(
                  snapshot.data!.data() as Map<String, dynamic>);
              return Text(
                user.name ?? user.email,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF262626),
                ),
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            model.description,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF262626),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/comment', arguments: model);
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: FutureBuilder(
              future: _cloudFirestoreHelper.getComments(model.postId),
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    '댓글 0개 모두 보기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF737373),
                    ),
                  );
                }
                final comments = snapshot.data!.docs
                    .map((e) => CommentModel.fromMap(e.data()))
                    .toList();

                return Text(
                  '댓글 ${comments.length}개 모두 보기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF737373),
                  ),
                );
              },
            ),
          ),
          Text(
            '${DateFormat('MM월 dd일').format(model.createdAt.toDate())}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF737373),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttons({required Function() onTap, required IconData icon}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon),
    );
  }
}

class BottomNavigator extends StatelessWidget {
  const BottomNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationBarProvider>(
      builder: (_, provider, __) {
        return BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (value) {
            provider.changeCurrentIndex(value);
            provider.moveTo(context, value);
          },
          currentIndex: provider.currentIndex,
          iconSize: 30,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: '',
            ),
          ],
        );
      },
    );
  }
}

/// 전체 게시물, 인기 게시물, 최신 게시물, 게시물 상세 end

/// 내 게시물 목록 start

class MyPostingsScreen extends StatelessWidget {
  MyPostingsScreen({super.key});

  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, provider, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            elevation: 0,
            centerTitle: true,
            title: Text(
              provider.myAccount!.name ?? provider.myAccount!.email,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF262626),
              ),
            ),
            actions: [
              PopupMenu(
                items: [
                  PopupMenuModel(
                    title: '내 북마크 게시물',
                    onTap: () =>
                        Navigator.pushNamed(context, '/bookmark_postings'),
                  ),
                  PopupMenuModel(
                    title: '내 좋아요 게시글',
                    onTap: () => Navigator.pushNamed(context, '/like_postings'),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    accountInfo(provider.myAccount!),
                    SizedBox(height: 8),
                    profileEditButton(context),
                    SizedBox(height: 12),
                    postings(context, provider.myAccount!.userId),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigator(),
        );
      },
    );
  }

  Widget accountInfo(UserModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD9D9D9),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  model.profileImg ?? '',
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.person_outline,
                      size: 44,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 44),
            FutureBuilder(
              future: _cloudFirestoreHelper.getPostings(model.userId),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return numbers(0, 'Posts');
                }
                final postings =
                    snapshot.data!.docs.map((e) => e.data()).toList();
                return numbers(postings.length, 'Posts');
              },
            ),
            numbers(model.followers.length, 'Followers'),
            numbers(model.following.length, 'Following'),
          ],
        ),
        SizedBox(height: 7),
        Text(
          model.name ?? model.email,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF262626),
          ),
        ),
        SizedBox(height: 5),
        model.introduction != null
            ? Text(
                model.introduction!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF262626),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget numbers(int num, String title) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Text(
            NumberFormat('###,###,###', 'en_US').format(num),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF262626),
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF262626),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileEditButton(BuildContext context) {
    return SizedBox(
      width: 343,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/my_account');
        },
        style: ElevatedButton.styleFrom(
          // TODO: textstyle의 color로 옮길지 의사결정 필요
          foregroundColor: Color(0xFF262626),
          backgroundColor: Color(0xFFEFEFEF),
          elevation: 0,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text('프로필 편집'),
      ),
    );
  }

  Widget postings(BuildContext context, String uid) {
    return FutureBuilder(
      future: _cloudFirestoreHelper.getPostings(uid),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 160),
            child: Text(
              '아직 게시물이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          );
        }
        final postings = snapshot.data!.docs.map((e) => e.data()).toList();
        if (postings.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 160),
            child: Text(
              '아직 게시물이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          itemCount: postings.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (_, index) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/posting',
                    arguments: postings[index]['post_id']);
              },
              child: Image.network(
                postings[index]['post_img'],
                width: 112,
                height: 112,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }
}

class OtherPostingsScreen extends StatelessWidget {
  OtherPostingsScreen({super.key});

  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as UserModel;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: Text(
          user.name ?? user.email,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                accountInfo(user),
                SizedBox(height: 8),
                followButton(context, user.userId),
                SizedBox(height: 12),
                postings(context, user.userId),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }

  Widget accountInfo(UserModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD9D9D9),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  model.profileImg ?? '',
                  width: 82,
                  height: 82,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      Icons.person_outline,
                      size: 44,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 44),
            FutureBuilder(
              future: _cloudFirestoreHelper.getPostings(model.userId),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return numbers(0, 'Posts');
                }
                final postings =
                    snapshot.data!.docs.map((e) => e.data()).toList();
                return numbers(postings.length, 'Posts');
              },
            ),
            numbers(model.followers.length, 'Followers'),
            numbers(model.following.length, 'Following'),
          ],
        ),
        SizedBox(height: 7),
        Text(
          model.name ?? model.email,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF262626),
          ),
        ),
        SizedBox(height: 5),
        model.introduction != null
            ? Text(
                model.introduction!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF262626),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget numbers(int num, String title) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Text(
            NumberFormat('###,###,###', 'en_US').format(num),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF262626),
            ),
          ),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF262626),
            ),
          ),
        ],
      ),
    );
  }

  Widget followButton(BuildContext context, String otherUserId) {
    return Consumer<AuthProvider>(
      builder: (_, provider, __) {
        final myAccount = provider.myAccount!;
        return SizedBox(
          width: 343,
          height: 36,
          child: ElevatedButton(
            onPressed: () {
              myAccount.following.contains(otherUserId)
                  ? _cloudFirestoreHelper.deleteFollow(
                      context,
                      myUserId: myAccount.userId,
                      otherUserId: otherUserId,
                    )
                  : _cloudFirestoreHelper.addFollow(
                      context,
                      myUserId: myAccount.userId,
                      otherUserId: otherUserId,
                    );
            },
            style: ElevatedButton.styleFrom(
              // TODO: textstyle의 color로 옮길지 의사결정 필요
              foregroundColor: myAccount.following.contains(otherUserId)
                  ? Color(0xFF262626)
                  : Colors.white,
              backgroundColor: myAccount.following.contains(otherUserId)
                  ? Color(0xFFEFEFEF)
                  : Color(0xFF3C95EF),
              elevation: 0,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(
                '${myAccount.following.contains(otherUserId) ? '팔로우 취소' : '팔로우 하기'}'),
          ),
        );
      },
    );
  }

  Widget postings(BuildContext context, String uid) {
    return FutureBuilder(
      future: _cloudFirestoreHelper.getPostings(uid),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(top: 160),
            child: Text(
              '아직 게시물이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          );
        }
        final postings = snapshot.data!.docs.map((e) => e.data()).toList();
        if (postings.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: 160),
            child: Text(
              '아직 게시물이 없습니다.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          );
        }
        return GridView.builder(
          shrinkWrap: true,
          itemCount: postings.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemBuilder: (_, index) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/posting',
                    arguments: postings[index]['post_id']);
              },
              child: Image.network(
                postings[index]['post_img'],
                width: 112,
                height: 112,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      },
    );
  }
}

class MyBookmarkPostingsScreen extends StatelessWidget {
  MyBookmarkPostingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '내 북마크 게시물',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, provider, __) {
          final postingIds = provider.myAccount!.bookmarkList;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: postingIds.length,
            itemBuilder: (_, index) {
              return Posting(postId: postingIds[index]);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}

class MyLikePostingsScreen extends StatelessWidget {
  const MyLikePostingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '내 좋아요 게시물',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, provider, __) {
          final postingIds = provider.myAccount!.likeList;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: postingIds.length,
            itemBuilder: (_, index) {
              return Posting(postId: postingIds[index]);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigator(),
    );
  }
}

class PopupMenu extends StatelessWidget {
  const PopupMenu({
    super.key,
    required this.items,
    this.icon = Icons.filter_alt_outlined,
  });

  final List<PopupMenuModel> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    // TODO: 배우지 않은 menuAnchor를 사용할지, 배웠지만 디자인이 애매한 PopupMenu를 사용할지
    return MenuAnchor(
      builder: (_, controller, __) {
        return IconButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: Icon(icon, color: Colors.black),
        );
      },
      alignmentOffset: Offset(0, -10),
      style: MenuStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        side: MaterialStateProperty.all(BorderSide(
          color: Color(0xFFDBDBDB),
        )),
      ),
      menuChildren: List.generate(
        items.length,
        (index) => MenuItemButton(
          onPressed: () {
            items[index].onTap();
          },
          style: ButtonStyle(
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            )),
            minimumSize: MaterialStateProperty.all(Size(0, 0)),
            side: index == items.length - 1
                ? null
                : MaterialStateProperty.all(BorderSide(
                    color: Color(0xFFDBDBDB),
                  )),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            items[index].title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
    // return PopupMenuButton<String>(
    //   icon: Icon(
    //     icon,
    //     color: Colors.black,
    //   ),
    //   iconSize: 24,
    //   offset: const Offset(0, -10),
    //   padding: const EdgeInsets.all(0),
    //   elevation: 25,
    //   constraints: const BoxConstraints(maxHeight: 100, maxWidth: 120),
    //   position: PopupMenuPosition.under,
    //   shape: RoundedRectangleBorder(
    //     side: const BorderSide(color: Color(0xFFDBDBDB), width: 0.7),
    //     borderRadius: BorderRadius.circular(5),
    //   ),
    //   onSelected: (String value) {
    //     final PopupMenuModel model =
    //         items[items.indexWhere((element) => element.title == value)];
    //     model.onTap();
    //   },
    //   itemBuilder: (context) {
    //     final popups = <PopupMenuEntry<String>>[];
    //     for (final PopupMenuModel item in items) {
    //       popups.add(
    //         PopupMenuItem<String>(
    //           value: item.title,
    //           height: 28,
    //           textStyle: TextStyle(
    //             color: Colors.black,
    //             fontSize: 12,
    //             fontWeight: FontWeight.w400,
    //           ),
    //           child: Text(
    //             item.title,
    //           ),
    //         ),
    //       );
    //       // 구분선 추가
    //       if (item != items.last) {
    //         popups.add(const PopupMenuDivider(height: 0.7));
    //       }
    //     }
    //     return popups;
    //   },
    // );
  }
}

class PopupMenuModel {
  final String title;
  final Function() onTap;

  PopupMenuModel({
    required this.title,
    required this.onTap,
  });
}

/// 내 게시물 목록 end

/// 내 정보 확인 start

class MyAccountScreen extends StatefulWidget {
  MyAccountScreen({super.key});

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  final AuthHelper _authHelper = AuthHelper();
  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _introductionController;

  @override
  void initState() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _emailController =
        TextEditingController(text: authProvider.myAccount!.email);
    _nameController = TextEditingController(text: authProvider.myAccount!.name);
    _introductionController =
        TextEditingController(text: authProvider.myAccount!.introduction);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 1,
        centerTitle: true,
        title: Text(
          '프로필 편집',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF151515),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _cloudFirestoreHelper.updateMyAccount(
                context,
                name: _nameController.text.isNotEmpty
                    ? _nameController.text
                    : null,
                introduction: _introductionController.text.isNotEmpty
                    ? _introductionController.text
                    : null,
              );
            },
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
      body: Center(
        child: Consumer<AuthProvider>(
          builder: (_, provider, __) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        // TODO: witdh: 94로 수정할 수 있는 방법
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD9D9D9),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            provider.myAccount!.profileImg ?? '',
                            width: 82,
                            height: 82,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Icon(
                                Icons.person_outline,
                                size: 44,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Color(0xFFD3D3D3), width: 1.5),
                            color: Colors.white,
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              final image =
                                  await Navigator.pushNamed(context, '/album');
                              if (image == null) {
                                return;
                              } else {
                                final imageUrl = image.toString();
                                _cloudFirestoreHelper.updateMyAccount(
                                  context,
                                  imageUrl: imageUrl,
                                );
                              }
                            },
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 18,
                              color: Color(0xFF707070),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  profileSection('이메일', _emailController, enable: false),
                  profileSection('이름', _nameController),
                  profileSection('소개', _introductionController),
                  SizedBox(height: 30),
                  signOutButton(
                    title: '로그아웃',
                    onTap: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/sign_in', (route) => false);
                      _authHelper.signOut();
                    },
                    color: Color(0xFFEA333E),
                  ),
                  SizedBox(height: 20),
                  signOutButton(
                    title: '회원탈퇴하기',
                    onTap: () {
                      _authHelper.withdraw();
                    },
                    color: Color(0xFF737373),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget profileSection(
    String title,
    TextEditingController controller, {
    bool? enable = true,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 94,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF262626),
            ),
          ),
        ),
        Spacer(),
        SizedBox(
          width: 240,
          child: TextField(
            enabled: enable,
            controller: controller,
          ),
        ),
      ],
    );
  }

  Widget signOutButton({
    required String title,
    required Function() onTap,
    required Color color,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// 내 정보 확인 end

/// 게시물 등록 start

class AddPostingScreen extends StatelessWidget {
  AddPostingScreen({super.key});

  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 1,
        centerTitle: true,
        title: Text(
          '새 게시물',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF151515),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _cloudFirestoreHelper.addPosting(context);
            },
            child: Text(
              '공유',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            profileSection(context),
            SizedBox(height: 20),
            imageSection(context),
            textFieldSection(context),
          ],
        ),
      ),
    );
  }

  Widget profileSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, provider, __) {
        return Row(
          children: [
            SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                provider.myAccount!.profileImg ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD9D9D9),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 10),
            Text(
              provider.myAccount!.name ?? provider.myAccount!.email,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF262626),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget imageSection(BuildContext context) {
    return Consumer<PostingProvider>(
      builder: (_, provider, __) {
        return Container(
          width: 375,
          height: 340,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFD9D9D9),
            image: DecorationImage(
              image: NetworkImage(
                provider.imageUrl ?? '',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: InkWell(
            onTap: () async {
              final image = await Navigator.pushNamed(context, '/album');
              if (image == null) {
                return;
              } else {
                final imageUrl = image.toString();
                provider.changeImageUrl(imageUrl);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFD3D3D3), width: 2),
                color: Colors.white.withOpacity(0.72),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget textFieldSection(BuildContext context) {
    return Container(
      width: 375,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<PostingProvider>(
          builder: (_, provider, __) {
            return TextField(
              controller: provider.controller!,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF262626),
              ),
              decoration: InputDecoration(
                hintText: '문구 입력 ...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF737373),
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            );
          },
        ),
      ),
    );
  }
}

class UpdatePostingScreen extends StatelessWidget {
  UpdatePostingScreen({super.key});

  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    final model = ModalRoute.of(context)!.settings.arguments as PostModel;
    Provider.of<PostingProvider>(context, listen: false)
        .changeImageUrl(model.postImg);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 1,
        centerTitle: true,
        title: Text(
          '정보 수정',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF151515),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _cloudFirestoreHelper.updatePosting(context, model.postId);
            },
            child: Text(
              '완료',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            profileSection(context),
            SizedBox(height: 20),
            imageSection(context),
            textFieldSection(context),
          ],
        ),
      ),
    );
  }

  Widget profileSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, provider, __) {
        return Row(
          children: [
            SizedBox(width: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                provider.myAccount!.profileImg ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD9D9D9),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 10),
            Text(
              provider.myAccount!.name ?? provider.myAccount!.email,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF262626),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget imageSection(BuildContext context) {
    return Consumer<PostingProvider>(
      builder: (_, provider, __) {
        return Container(
          width: 375,
          height: 340,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFFD9D9D9),
            image: DecorationImage(
              image: NetworkImage(
                provider.imageUrl ?? '',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: InkWell(
            onTap: () async {
              final image = await Navigator.pushNamed(context, '/album');
              if (image == null) {
                return;
              } else {
                final imageUrl = image.toString();
                provider.changeImageUrl(imageUrl);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFD3D3D3), width: 2),
                color: Colors.white.withOpacity(0.72),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                size: 20,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget textFieldSection(BuildContext context) {
    return Container(
      width: 375,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<PostingProvider>(
          builder: (_, provider, __) {
            return TextField(
              controller: provider.controller!,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF262626),
              ),
              decoration: InputDecoration(
                hintText: '문구 입력 ...',
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF737373),
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AlbumScreen extends StatelessWidget {
  const AlbumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 1,
        centerTitle: true,
        title: Text(
          '앨범에서 선택',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
        leading: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            '취소',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF151515),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: GridView.builder(
            itemCount: albumImages.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  Navigator.pop(context, albumImages[index]);
                },
                child: Image.network(
                  albumImages[index],
                  width: 112,
                  height: 112,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 게시물 등록 end

/// 댓글 start

class CommentScreen extends StatelessWidget {
  CommentScreen({super.key});

  final CloudFirestoreHelper _cloudFirestoreHelper = CloudFirestoreHelper();

  @override
  Widget build(BuildContext context) {
    final model = ModalRoute.of(context)!.settings.arguments as PostModel;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          '댓글',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF262626),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(15, 16, 15, 12),
              child: postSection(context, model),
            ),
            Divider(),
            commentSection(context, model),
          ],
        ),
      ),
      bottomSheet: commentInputSection(context, model),
    );
  }

  Widget postSection(BuildContext context, PostModel model) {
    return FutureBuilder(
      future: _cloudFirestoreHelper.getOneUser(model.userId),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        final user =
            UserModel.fromMap(snapshot.data!.data() as Map<String, dynamic>);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                user.profileImg ?? '',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFD9D9D9),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 40,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? user.email,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF262626),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  model.description,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF262626),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget commentSection(BuildContext context, PostModel model) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 86),
      child: StreamBuilder(
        stream: _cloudFirestoreHelper.getCommentsStream(model.postId),
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          final comments = snapshot.data!.docs
              .map((e) => CommentModel.fromMap(e.data()))
              .toList();
          return Column(
            children: List.generate(
              comments.length,
              (index) => FutureBuilder(
                future:
                    _cloudFirestoreHelper.getOneUser(comments[index].userId),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  final user = UserModel.fromMap(
                      snapshot.data!.data() as Map<String, dynamic>);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            user.profileImg ?? '',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFD9D9D9),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name ?? user.email,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF262626),
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: 265,
                              child: Text(
                                comments[index].description,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF262626),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        Provider.of<AuthProvider>(context, listen: false)
                                    .myAccount!
                                    .userId ==
                                user.userId
                            ? GestureDetector(
                                onTap: () {
                                  _cloudFirestoreHelper.deleteComment(
                                    postId: model.postId,
                                    commentId: comments[index].commentId,
                                  );
                                },
                                child: Icon(Icons.delete_outline, size: 18),
                              )
                            : SizedBox(),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget commentInputSection(BuildContext context, PostModel model) {
    final TextEditingController _commentController = TextEditingController();
    return Consumer<AuthProvider>(
      builder: (_, provider, __) {
        return Container(
          height: 70,
          width: 375,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(16, 0, 16, 30),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  provider.myAccount!.profileImg ?? '',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD9D9D9),
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              SizedBox(
                width: 287,
                child: TextField(
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF737373),
                  ),
                  controller: _commentController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFDBDBDB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFDBDBDB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    hoverColor: Colors.transparent,
                    hintText: '댓글 달기 ...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF737373),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    suffixIcon: TextButton(
                      onPressed: () {
                        _cloudFirestoreHelper.addComment(
                          context,
                          content: _commentController.text,
                          postId: model.postId,
                        );
                        _commentController.clear();
                      },
                      child: Text(
                        '게시',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3C95EF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 댓글 end

/// helper class start

class AuthHelper {
  var _auth = FirebaseAuth.instance;
  final CloudFirestoreHelper _firestoreHelper = CloudFirestoreHelper();

  /// 로그인
  Future<bool> signInEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final res = await _firestoreHelper.getOneUser(credential.user!.uid);
        final UserModel user =
            UserModel.fromMap(res.data() as Map<String, dynamic>);
        Provider.of<AuthProvider>(context, listen: false).changeMyAccount(user);
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// 회원가입
  Future<UserModel?> signUpEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        final UserModel user = UserModel(
          userId: credential.user!.uid,
          name: null,
          email: credential.user!.email!,
          introduction: null,
          profileImg: null,
          followers: [],
          following: [],
          isDeleted: false,
          signupAt: Timestamp.now(),
          bookmarkList: [],
          likeList: [],
        );
        _firestoreHelper.createAccount(userModel: user);
        return user;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  /// 이메일 검증
  void sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  /// 비밀번호 재설정
  void sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// 로그아웃
  void signOut() async {
    await _auth.signOut();
  }

  /// 탈퇴
  void withdraw() async {
    await _auth.currentUser!.delete();
    await _auth.signOut();
  }
}

class CloudFirestoreHelper {
  var _firestore = FirebaseFirestore.instance;

  final StorageHelper _storageHelper = StorageHelper();

  void createAccount({
    required UserModel userModel,
  }) {
    _firestore.collection('Users').doc(userModel.userId).set(userModel.toMap());
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostings(String uid) async {
    return _firestore
        .collection('Posts')
        .where('user_id', isEqualTo: uid)
        .get();
  }

  void addPosting(BuildContext context) async {
    final postingProvider =
        Provider.of<PostingProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final url = await _storageHelper.uploadPostingImage(
        Timestamp.now().microsecondsSinceEpoch.toString(),
        postingProvider.imageUrl!);
    if (url == null) return;
    final reference = _firestore.collection('Posts').doc();
    final PostModel model = PostModel(
      postId: reference.id,
      userId: authProvider.myAccount!.userId,
      description: postingProvider.controller!.text,
      postImg: url,
      createdAt: Timestamp.now(),
      likeList: [],
      likeNum: 0,
    );
    reference.set(model.toMap()).whenComplete(() {
      Navigator.popAndPushNamed(context, '/posting', arguments: reference.id);
    });
  }

  void updatePosting(BuildContext context, String postId) async {
    final postingProvider =
        Provider.of<PostingProvider>(context, listen: false);
    final url = await _storageHelper.uploadPostingImage(
        Timestamp.now().microsecondsSinceEpoch.toString(),
        postingProvider.imageUrl!);
    if (url == null) return;
    final reference = _firestore.collection('Posts').doc(postId);
    reference.set({
      'description': postingProvider.controller!.text,
      'post_img': url,
    }, SetOptions(merge: true)).whenComplete(() {
      Navigator.pop(context);
    });
  }

  void deletePosting(BuildContext context, String postId) async {
    final reference = _firestore.collection('Posts').doc(postId);
    reference.delete();
  }

  Future<PostModel> likePosting(BuildContext context, PostModel model) async {
    final postId = model.postId;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myAccount = authProvider.myAccount!;
    final postReference = _firestore.collection('Posts').doc(postId);
    final userReference = _firestore.collection('Users').doc(myAccount.userId);
    if (myAccount.likeList.contains(postId)) {
      postReference.update({
        'like_list': FieldValue.arrayRemove([myAccount.userId]),
        'like_num': FieldValue.increment(-1),
      });
      userReference.update({
        'like_list': FieldValue.arrayRemove([postId]),
      });
      // TODO: 위와 같은 기능
      // userReference.set({
      //   'like_list': FieldValue.arrayRemove([postId]),
      // }, SetOptions(merge: true));
      myAccount.likeList.remove(postId);
      model.likeList.remove(myAccount.userId);
      model = model.copyWith(likeNum: model.likeNum - 1);
      authProvider.changeMyAccount(myAccount);
    } else {
      postReference.update({
        'like_list': FieldValue.arrayUnion([myAccount.userId]),
        'like_num': FieldValue.increment(1),
      });
      userReference.update({
        'like_list': FieldValue.arrayUnion([postId]),
      });
      // TODO: 위와 같은 기능
      // userReference.set({
      //   'like_list': FieldValue.arrayRemove([postId]),
      // }, SetOptions(merge: true));
      myAccount.likeList.add(postId);
      model.likeList.add(myAccount.userId);
      model = model.copyWith(likeNum: model.likeNum + 1);
      authProvider.changeMyAccount(myAccount);
    }
    return model;
  }

  void bookmarkPosting(BuildContext context, String postId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myAccount = authProvider.myAccount!;
    final userReference = _firestore.collection('Users').doc(myAccount.userId);
    if (myAccount.bookmarkList.contains(postId)) {
      userReference.update({
        'bookmark_list': FieldValue.arrayRemove([postId]),
      });
      myAccount.bookmarkList.remove(postId);
      authProvider.changeMyAccount(myAccount);
    } else {
      userReference.update({
        'bookmark_list': FieldValue.arrayUnion([postId]),
      });
      myAccount.bookmarkList.add(postId);
      authProvider.changeMyAccount(myAccount);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getComments(String postId) async {
    return _firestore
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCommentsStream(String postId) {
    return _firestore
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .orderBy('created_at')
        .snapshots();
  }

  void addComment(
    BuildContext context, {
    required String content,
    required String postId,
  }) async {
    final myAccount =
        Provider.of<AuthProvider>(context, listen: false).myAccount!;
    final reference =
        _firestore.collection('Posts').doc(postId).collection('Comments').doc();
    final CommentModel model = CommentModel(
      commentId: reference.id,
      userId: myAccount.userId,
      description: content,
      createdAt: Timestamp.now(),
    );
    reference.set(model.toMap());
  }

  void deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final reference = _firestore
        .collection('Posts')
        .doc(postId)
        .collection('Comments')
        .doc(commentId);
    reference.delete();
  }

  void addFollow(
    BuildContext context, {
    required String myUserId,
    required String otherUserId,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myAccount = authProvider.myAccount!;
    final myRef = _firestore.collection('Users').doc(myUserId);
    final otherRef = _firestore.collection('Users').doc(otherUserId);
    myRef.update({
      'following': FieldValue.arrayUnion([otherUserId]),
    });
    otherRef.update({
      'followers': FieldValue.arrayUnion([myUserId]),
    });
    myAccount.following.add(otherUserId);
    authProvider.changeMyAccount(myAccount);
  }

  void deleteFollow(
    BuildContext context, {
    required String myUserId,
    required String otherUserId,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myAccount = authProvider.myAccount!;
    final myRef = _firestore.collection('Users').doc(myUserId);
    final otherRef = _firestore.collection('Users').doc(otherUserId);
    myRef.update({
      'following': FieldValue.arrayRemove([otherUserId]),
    });
    otherRef.update({
      'followers': FieldValue.arrayRemove([myUserId]),
    });
    myAccount.following.remove(otherUserId);
    authProvider.changeMyAccount(myAccount);
  }

  void updateMyAccount(
    BuildContext context, {
    String? name,
    String? introduction,
    String? imageUrl,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final UserModel myAccount = authProvider.myAccount!;
    name = name ?? myAccount.name;
    introduction = introduction ?? myAccount.introduction;
    imageUrl = imageUrl ?? myAccount.profileImg;
    String? profileImg;
    if (imageUrl != null) {
      profileImg = await _storageHelper.uploadPostingImage(
        Timestamp.now().microsecondsSinceEpoch.toString(),
        imageUrl,
      );
    }
    final reference = _firestore.collection('Users').doc(myAccount.userId);
    reference.set({
      'name': name,
      'introduction': introduction,
      'profile_img': profileImg,
    }, SetOptions(merge: true)).whenComplete(() {
      authProvider.changeMyAccount(myAccount.copyWith(
        name: name,
        introduction: introduction,
        profileImg: profileImg,
      ));
      Navigator.pop(context);
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOnePosting(
      String postId) async {
    return _firestore.collection('Posts').doc(postId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getOneUser(
      String userId) async {
    return _firestore.collection('Users').doc(userId).get();
  }

  // TODO: 전체 게시글에는 어떤 filter가 들어가야 할지 결정 필요함
  Future<QuerySnapshot<Map<String, dynamic>>> getAllPostings() async {
    return _firestore.collection('Posts').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getNewPostings() async {
    return _firestore.collection('Posts').orderBy('created_at').get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getHotPostings() async {
    return _firestore
        .collection('Posts')
        .orderBy('like_num', descending: true)
        .get();
  }
}

class StorageHelper {
  var storage = FirebaseStorage.instance;

  Future<String?> uploadPostingImage(String imageName, String imageUrl) async {
    final imageRef = storage.ref().child("post_image/$imageName.jpg");
    final data = await getImage(url: imageUrl);

    if (data == null) return null;
    try {
      await imageRef.putData(data, SettableMetadata(contentType: 'image/jpg'));
      final url = await imageRef.getDownloadURL();
      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Uint8List?> getImage({String? url}) async {
    try {
      final res =
          await http.get(Uri.parse(url ?? 'https://picsum.photos/300/200'));
      if (res.statusCode == 200) {
        return res.bodyBytes;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}

/// helper class end

/// provider class start

class AuthProvider with ChangeNotifier {
  // TODO: UserModel? myAccount;으로 수정
  UserModel? myAccount = UserModel.init();

  void changeMyAccount(UserModel value) {
    myAccount = value;
    notifyListeners();
  }
}

class BottomNavigationBarProvider with ChangeNotifier {
  int currentIndex = 0;

  void changeCurrentIndex(int value) {
    currentIndex = value;
    notifyListeners();
  }

  void moveTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/all_postings');
        break;
      case 1:
        Provider.of<PostingProvider>(context, listen: false).initData();
        Navigator.pushNamed(context, '/add_posting');
        break;
      case 2:
        Navigator.pushNamed(context, '/my_postings');
        break;
    }
  }
}

class PostingProvider with ChangeNotifier {
  String? imageUrl;
  TextEditingController? controller;

  void initData() {
    imageUrl = null;
    controller = TextEditingController();
    notifyListeners();
  }

  void changeImageUrl(String url) {
    imageUrl = url;
    notifyListeners();
  }

  void changeDescription(String description) {
    controller?.text = '';
  }
}

/// provider class end

/// model start

class PostModel {
  final String postId;
  final String userId;
  final String description;
  final String postImg;
  final Timestamp createdAt;
  final List<String> likeList;
  final int likeNum;
//   final List<CommentModel> commentList;

  const PostModel({
    required this.postId,
    required this.userId,
    required this.description,
    required this.postImg,
    required this.createdAt,
    required this.likeList,
    required this.likeNum,
//     required this.commentList,
  });

  PostModel copyWith({
    String? postId,
    String? userId,
    String? description,
    String? postImg,
    Timestamp? createdAt,
    List<String>? likeList,
    int? likeNum,
  }) {
    return PostModel(
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      postImg: postImg ?? this.postImg,
      createdAt: createdAt ?? this.createdAt,
      likeList: likeList ?? List.from(this.likeList),
      likeNum: likeNum ?? this.likeNum,
    );
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['post_id'],
      userId: map['user_id'],
      description: map['description'],
      postImg: map['post_img'],
      createdAt: map['created_at'],
      likeList: List<String>.from(map['like_list'] as List<dynamic>),
      likeNum: map['like_num'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'post_id': postId,
      'user_id': userId,
      'description': description,
      'post_img': postImg,
      'created_at': createdAt,
      'like_list': likeList,
      'like_num': likeNum,
    };
  }
}

class CommentModel {
  final String commentId;
  final String userId;
  final String description;
  final Timestamp createdAt;

  const CommentModel({
    required this.commentId,
    required this.userId,
    required this.description,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['comment_id'],
      userId: map['user_id'],
      description: map['description'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'comment_id': commentId,
      'user_id': userId,
      'description': description,
      'created_at': createdAt,
    };
  }
}

class UserModel {
  final String userId;
  final String? name;
  final String email;
  final String? introduction;
  final String? profileImg;
  final List<String> followers;
  final List<String> following;
  final bool isDeleted;
  final Timestamp signupAt;
  final List<String> bookmarkList;
  final List<String> likeList;

  const UserModel({
    required this.userId,
    this.name,
    required this.email,
    this.introduction,
    this.profileImg,
    required this.followers,
    required this.following,
    required this.isDeleted,
    required this.signupAt,
    required this.bookmarkList,
    required this.likeList,
  });

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? introduction,
    String? profileImg,
    List<String>? followers,
    List<String>? following,
    bool? isDeleted,
    Timestamp? signupAt,
    List<String>? bookmarkList,
    List<String>? likeList,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      introduction: introduction ?? this.introduction,
      profileImg: profileImg ?? this.profileImg,
      followers: followers ?? List.from(this.followers),
      following: following ?? List.from(this.following),
      isDeleted: isDeleted ?? this.isDeleted,
      signupAt: signupAt ?? this.signupAt,
      bookmarkList: bookmarkList ?? List.from(this.bookmarkList),
      likeList: likeList ?? List.from(this.likeList),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'],
      name: map['name'],
      email: map['email'],
      introduction: map['introduction'],
      profileImg: map['profile_img'],
      followers: List<String>.from(map['followers'] as List<dynamic>),
      following: List<String>.from(map['following'] as List<dynamic>),
      isDeleted: map['is_deleted'],
      signupAt: map['signup_at'],
      bookmarkList: List<String>.from(map['bookmark_list'] as List<dynamic>),
      likeList: List<String>.from(map['like_list'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'name': name,
      'email': email,
      'introduction': introduction,
      'profile_img': profileImg,
      'followers': followers,
      'following': following,
      'is_deleted': isDeleted,
      'signup_at': signupAt,
      'bookmark_list': bookmarkList,
      'like_list': likeList,
    };
  }

  // TODO: 삭제 해야됨
  static UserModel init() => UserModel(
        userId: 'RWTgiOqE50b6hgh0Yh5Y1eCNymW2',
        email: 'email',
        followers: [],
        following: [],
        isDeleted: false,
        signupAt: Timestamp.now(),
        bookmarkList: [],
        likeList: [],
      );
}

/// model end

/// const data start

final albumImages = [
  'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2Fimage1.jpg?alt=media&token=c1511475-a259-48f1-80c7-6b9cb1087522',
  'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2Fimage2.jpg?alt=media&token=1dd26e16-b6e3-4c28-8f97-28747b086dae',
  'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2Fimage3.jpg?alt=media&token=c4732759-d336-4b61-b13a-8c4920764eaa',
  'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2Fimage4.jpg?alt=media&token=23953feb-163d-4466-80db-4afcaebe0809',
  'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2Fimage5.jpg?alt=media&token=ba823291-846c-406c-b701-965d2ba93d28',
  'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2Fimage6.jpg?alt=media&token=72b08192-ebad-475b-ad8a-9840e2a580f5',
  'https://firebasestorage.googleapis.com/v0/b/course4-microproject-test.appspot.com/o/images%2Fimage7.jpg?alt=media&token=0576453c-5f2b-4406-870a-84175761c2ef',
];

/// const data end
