cmake_minimum_required(VERSION 3.16)

project(markdownnote)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(KF6 REQUIRED COMPONENTS Plasma)
find_package(Qt6 REQUIRED COMPONENTS Gui Qml)

plasma_install_package(. org.kde.plasma6.markdownnote)
