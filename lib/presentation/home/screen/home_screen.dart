import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ikara_clone/constants/constants.dart';
import 'package:ikara_clone/presentation/common/widgets/app_icon.dart';
import 'package:ikara_clone/presentation/home/bloc/bottom_navigator_bloc.dart';

class HomeScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BottomNavigatorBloc, BottomNavigatorState>(
      listener: (context, state) {
        navigationShell.goBranch(
          state.index,
          initialLocation: state.index == navigationShell.currentIndex,
        );
      },
      child: BlocBuilder<BottomNavigatorBloc, BottomNavigatorState>(
        builder: (context, state) {
          return SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: navigationShell,
              bottomNavigationBar: SizedBox(
                height: 68,
                child: BottomNavigationBar(
                  selectedFontSize: 12,
                  unselectedFontSize: 10,
                  currentIndex: state.index,
                  backgroundColor: AppColors.bottomNavigationBar,
                  selectedItemColor: AppColors.selectionColor,
                  unselectedItemColor: AppColors.unSelection,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle: TextStyle(fontFamily: 'Roboto'),
                  unselectedLabelStyle: TextStyle(fontFamily: 'Roboto'),
                  type: BottomNavigationBarType.fixed,
                  onTap: (index) {
                    context.read<BottomNavigatorBloc>().add(
                      ChangeTabEvent(index),
                    );
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: AppIcon(
                        assetPath: "assets/icons/music.svg",
                        active: false,
                      ),
                      activeIcon: AppIcon(
                        assetPath: "assets/icons/music.svg",
                        activePath: "assets/icons/music_color.svg",
                        active: true,
                      ),
                      label: "Bài học",
                    ),
                    BottomNavigationBarItem(
                      icon: AppIcon(
                        assetPath: "assets/icons/microphone-2.svg",
                        active: false,
                      ),
                      activeIcon: AppIcon(
                        assetPath: "assets/icons/microphone-2.svg",
                        activePath: "assets/icons/microphone_color.svg",
                        active: true,
                      ),
                      label: "Luyện thanh",
                    ),
                    BottomNavigationBarItem(
                      icon: AppIcon(
                        assetPath: "assets/icons/wind.svg",
                        active: false,
                      ),
                      activeIcon: AppIcon(
                        assetPath: "assets/icons/wind.svg",
                        activePath: "assets/icons/wind_color.svg",
                        active: true,
                      ),
                      label: "Luyện thở",
                    ),
                    BottomNavigationBarItem(
                      icon: AppIcon(
                        assetPath: "assets/icons/music_note.svg",
                        active: false,
                      ),
                      activeIcon: AppIcon(
                        assetPath: "assets/icons/music_note.svg",
                        activePath: "assets/icons/music_note_color.svg",
                        active: true,
                      ),
                      label: "Luyện nhịp",
                    ),
                    BottomNavigationBarItem(
                      icon: AppIcon(
                        assetPath: "assets/icons/microphone-3.svg",
                        active: false,
                      ),
                      activeIcon: AppIcon(
                        assetPath: "assets/icons/microphone-3.svg",
                        activePath: "assets/icons/microphone_2_color.svg",
                        active: true,
                      ),
                      label: "Trình diễn",
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
