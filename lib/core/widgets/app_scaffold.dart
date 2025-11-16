import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import 'app_drawer.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.body,
    required this.authController,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.appBar,
  });

  final Widget body;
  final AuthController authController;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
      _controller.reverse();
    } else {
      _scaffoldKey.currentState?.openDrawer();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        authController: widget.authController,
        onNavigate: (route) {
          Navigator.of(context).pop();
          _controller.reverse();
          if (route != '/') {
            Navigator.of(context).pushNamed(route);
          }
        },
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final slide = 260 * _controller.value;
          final scale = 1 - (_controller.value * 0.1);
          return Transform(
            transform: Matrix4.identity()
              ..translate(slide)
              ..scale(scale),
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                  _controller.reverse();
                }
              },
              child: child,
            ),
          );
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: widget.appBar ??
              AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: _toggleDrawer,
                ),
                title: const Text('EV Smart'),
              ),
          body: widget.body,
          bottomNavigationBar: widget.bottomNavigationBar,
          floatingActionButton: widget.floatingActionButton,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
