import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_zgh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('zgh')
  ];

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @dataCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Collection'**
  String get dataCollectionTitle;

  /// No description provided for @dataCollectionDesc.
  ///
  /// In en, this message translates to:
  /// **'We only collect information necessary to improve your app experience. This may include your app usage patterns, preferences, and settings.'**
  String get dataCollectionDesc;

  /// No description provided for @dataUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Usage'**
  String get dataUsageTitle;

  /// No description provided for @dataUsageDesc.
  ///
  /// In en, this message translates to:
  /// **'Your data is used to enhance app functionality, personalize content, and ensure the best performance. We do not sell your data to third parties.'**
  String get dataUsageDesc;

  /// No description provided for @thirdPartyTitle.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get thirdPartyTitle;

  /// No description provided for @thirdPartyDesc.
  ///
  /// In en, this message translates to:
  /// **'Some features may use trusted third-party services (like analytics or ads). These services follow their own privacy policies.'**
  String get thirdPartyDesc;

  /// No description provided for @yourRightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRightsTitle;

  /// No description provided for @yourRightsDesc.
  ///
  /// In en, this message translates to:
  /// **'You have the right to request data deletion, access stored data, and opt out of optional tracking features.'**
  String get yourRightsDesc;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @sfxMusic.
  ///
  /// In en, this message translates to:
  /// **'Sfx Music'**
  String get sfxMusic;

  /// No description provided for @ourMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMissionTitle;

  /// No description provided for @ourMissionContent.
  ///
  /// In en, this message translates to:
  /// **'To bring the excitement of traditional Moroccan card games to mobile platforms with engaging visuals and gamified experiences.'**
  String get ourMissionContent;

  /// No description provided for @futurePlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Future Plans'**
  String get futurePlansTitle;

  /// No description provided for @futurePlansContent.
  ///
  /// In en, this message translates to:
  /// **'We plan to add multiplayer tournaments, new cards and themes, and interactive leaderboards to enhance the gaming experience.'**
  String get futurePlansContent;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Social Media'**
  String get followUs;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @tapAnywhereToCollect.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to collect'**
  String get tapAnywhereToCollect;

  /// No description provided for @adFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Ad failed to load. Try again later'**
  String get adFailedToLoad;

  /// No description provided for @shopNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'SHOP Not Available'**
  String get shopNotAvailable;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get comingSoon;

  /// No description provided for @notConnectedToInternet.
  ///
  /// In en, this message translates to:
  /// **'You are not connected to the internet'**
  String get notConnectedToInternet;

  /// No description provided for @playWithoutInternet.
  ///
  /// In en, this message translates to:
  /// **'Play without internet. Great for practicing!'**
  String get playWithoutInternet;

  /// No description provided for @challenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get challenge;

  /// No description provided for @playersInThisMode.
  ///
  /// In en, this message translates to:
  /// **'Players in this mode'**
  String get playersInThisMode;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @wins3Players.
  ///
  /// In en, this message translates to:
  /// **'Wins 3 Players'**
  String get wins3Players;

  /// No description provided for @wins4Players.
  ///
  /// In en, this message translates to:
  /// **'Wins 4 Players'**
  String get wins4Players;

  /// No description provided for @wins5Players.
  ///
  /// In en, this message translates to:
  /// **'Wins 5 Players'**
  String get wins5Players;

  /// No description provided for @skins.
  ///
  /// In en, this message translates to:
  /// **'Skins'**
  String get skins;

  /// No description provided for @avatars.
  ///
  /// In en, this message translates to:
  /// **'Avatars'**
  String get avatars;

  /// No description provided for @tables.
  ///
  /// In en, this message translates to:
  /// **'Tables'**
  String get tables;

  /// No description provided for @editUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit Username'**
  String get editUsername;

  /// No description provided for @enterNewUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter new username'**
  String get enterNewUsername;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @wins1v1.
  ///
  /// In en, this message translates to:
  /// **'Wins 1v1'**
  String get wins1v1;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get player;

  /// No description provided for @youCanSpinAgainIn.
  ///
  /// In en, this message translates to:
  /// **'You can spin again in'**
  String get youCanSpinAgainIn;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @cooldownReset.
  ///
  /// In en, this message translates to:
  /// **'Cooldown reset! You can spin now.'**
  String get cooldownReset;

  /// No description provided for @spin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get spin;

  /// No description provided for @spinWheel.
  ///
  /// In en, this message translates to:
  /// **'Spin Wheel'**
  String get spinWheel;

  /// No description provided for @timerReady.
  ///
  /// In en, this message translates to:
  /// **'Timer Ready'**
  String get timerReady;

  /// No description provided for @spinAgain.
  ///
  /// In en, this message translates to:
  /// **'Spin Again'**
  String get spinAgain;

  /// No description provided for @cardSkins.
  ///
  /// In en, this message translates to:
  /// **'Card Skins'**
  String get cardSkins;

  /// No description provided for @tableSkins.
  ///
  /// In en, this message translates to:
  /// **'Table Skins'**
  String get tableSkins;

  /// No description provided for @notEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough'**
  String get notEnough;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @tableSkinUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Table Skin Unlocked!'**
  String get tableSkinUnlocked;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome'**
  String get awesome;

  /// No description provided for @unlockTableSkin.
  ///
  /// In en, this message translates to:
  /// **'Unlock Table Skin'**
  String get unlockTableSkin;

  /// No description provided for @unlockCard.
  ///
  /// In en, this message translates to:
  /// **'Unlock Card'**
  String get unlockCard;

  /// No description provided for @avatarUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Avatar Unlocked'**
  String get avatarUnlocked;

  /// No description provided for @unlockAvatar.
  ///
  /// In en, this message translates to:
  /// **'Unlock Avatar'**
  String get unlockAvatar;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @unlockFor.
  ///
  /// In en, this message translates to:
  /// **'Unlock for'**
  String get unlockFor;

  /// No description provided for @cardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Card Unlocked'**
  String get cardUnlocked;

  /// No description provided for @mythical.
  ///
  /// In en, this message translates to:
  /// **'Mythical'**
  String get mythical;

  /// No description provided for @fantasy.
  ///
  /// In en, this message translates to:
  /// **'Fantasy'**
  String get fantasy;

  /// No description provided for @avatarSkins.
  ///
  /// In en, this message translates to:
  /// **'Avatar Skins'**
  String get avatarSkins;

  /// No description provided for @cardMaster.
  ///
  /// In en, this message translates to:
  /// **'CardMaster'**
  String get cardMaster;

  /// No description provided for @elements.
  ///
  /// In en, this message translates to:
  /// **'Elements'**
  String get elements;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @chooseASuit.
  ///
  /// In en, this message translates to:
  /// **'Choose a Suit'**
  String get chooseASuit;

  /// No description provided for @confirmLeaveGame.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to leave the game'**
  String get confirmLeaveGame;

  /// No description provided for @returnToLauncher.
  ///
  /// In en, this message translates to:
  /// **'and return to the launcher?'**
  String get returnToLauncher;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @gameSetupAndControls.
  ///
  /// In en, this message translates to:
  /// **'Game Setup & Controls'**
  String get gameSetupAndControls;

  /// No description provided for @chooseMode.
  ///
  /// In en, this message translates to:
  /// **'Choose mode:\nPlayToWin or Elimination'**
  String get chooseMode;

  /// No description provided for @suitsAndRanks.
  ///
  /// In en, this message translates to:
  /// **'• 4 Suits / 10 Ranks\n• Choose The Same Suit Or Same Rank'**
  String get suitsAndRanks;

  /// No description provided for @specialCardsAndEffects.
  ///
  /// In en, this message translates to:
  /// **'Special Cards & Effects'**
  String get specialCardsAndEffects;

  /// No description provided for @skipsNextPlayerTurn.
  ///
  /// In en, this message translates to:
  /// **'Skips the next player\'s turn.'**
  String get skipsNextPlayerTurn;

  /// No description provided for @skipCard.
  ///
  /// In en, this message translates to:
  /// **'1: Skip'**
  String get skipCard;

  /// No description provided for @drawTwoCard.
  ///
  /// In en, this message translates to:
  /// **'2: Draw +2'**
  String get drawTwoCard;

  /// No description provided for @drawTwoEffect.
  ///
  /// In en, this message translates to:
  /// **'Adds +2 to pending draw.\n• Can chain with another 2.'**
  String get drawTwoEffect;

  /// No description provided for @changeSuitCard.
  ///
  /// In en, this message translates to:
  /// **'7: Change Suit'**
  String get changeSuitCard;

  /// No description provided for @changeSuitEffect.
  ///
  /// In en, this message translates to:
  /// **'• Allows player to change the suit.'**
  String get changeSuitEffect;

  /// No description provided for @gameplayTips.
  ///
  /// In en, this message translates to:
  /// **'Gameplay Tips'**
  String get gameplayTips;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'Tip #1'**
  String get tip1;

  /// No description provided for @tip1Description.
  ///
  /// In en, this message translates to:
  /// **'Aim to empty your hand first in PlayToWin mode.'**
  String get tip1Description;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'Tip #2'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'Tip #3'**
  String get tip3;

  /// No description provided for @tip3Description.
  ///
  /// In en, this message translates to:
  /// **'Watch for special combos (1,2,7) to control the flow.'**
  String get tip3Description;

  /// No description provided for @winningGold.
  ///
  /// In en, this message translates to:
  /// **'Winning Gold'**
  String get winningGold;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @warriors.
  ///
  /// In en, this message translates to:
  /// **'Warriors'**
  String get warriors;

  /// No description provided for @notEnoughGoldForAnimation.
  ///
  /// In en, this message translates to:
  /// **'Not enough gold to use this animation'**
  String get notEnoughGoldForAnimation;

  /// No description provided for @bot.
  ///
  /// In en, this message translates to:
  /// **'Bot'**
  String get bot;

  /// No description provided for @qualified.
  ///
  /// In en, this message translates to:
  /// **'Qualified'**
  String get qualified;

  /// No description provided for @eliminated.
  ///
  /// In en, this message translates to:
  /// **'ELIMINATED'**
  String get eliminated;

  /// No description provided for @prizes.
  ///
  /// In en, this message translates to:
  /// **'Prizes'**
  String get prizes;

  /// No description provided for @rewardDistribution.
  ///
  /// In en, this message translates to:
  /// **'Reward Distribution'**
  String get rewardDistribution;

  /// No description provided for @totalPool.
  ///
  /// In en, this message translates to:
  /// **'Total Pool'**
  String get totalPool;

  /// No description provided for @bet.
  ///
  /// In en, this message translates to:
  /// **'Bet'**
  String get bet;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @redirectingIn.
  ///
  /// In en, this message translates to:
  /// **'Redirecting in'**
  String get redirectingIn;

  /// No description provided for @searchingForPlayers.
  ///
  /// In en, this message translates to:
  /// **'Searching for players...'**
  String get searchingForPlayers;

  /// No description provided for @matchFound.
  ///
  /// In en, this message translates to:
  /// **'⚡ Match Found'**
  String get matchFound;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnection;

  /// No description provided for @earnOrBuyGold.
  ///
  /// In en, this message translates to:
  /// **'Earn or buy more gold to place this bet.'**
  String get earnOrBuyGold;

  /// No description provided for @notEnoughGold.
  ///
  /// In en, this message translates to:
  /// **'Not Enough Gold!'**
  String get notEnoughGold;

  /// No description provided for @startMatch.
  ///
  /// In en, this message translates to:
  /// **'Start Match'**
  String get startMatch;

  /// No description provided for @startElimination.
  ///
  /// In en, this message translates to:
  /// **'Start Elimination'**
  String get startElimination;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @elim.
  ///
  /// In en, this message translates to:
  /// **'Elim'**
  String get elim;

  /// No description provided for @lobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get lobby;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @drawPile.
  ///
  /// In en, this message translates to:
  /// **'Draw Pile'**
  String get drawPile;

  /// No description provided for @topCard.
  ///
  /// In en, this message translates to:
  /// **'Top Card'**
  String get topCard;

  /// No description provided for @out.
  ///
  /// In en, this message translates to:
  /// **'OUT'**
  String get out;

  /// No description provided for @qual.
  ///
  /// In en, this message translates to:
  /// **'QUAL'**
  String get qual;

  /// No description provided for @turn.
  ///
  /// In en, this message translates to:
  /// **'TURN'**
  String get turn;

  /// No description provided for @leaveGame.
  ///
  /// In en, this message translates to:
  /// **'Leave Game'**
  String get leaveGame;

  /// No description provided for @spectating.
  ///
  /// In en, this message translates to:
  /// **'Spectating'**
  String get spectating;

  /// No description provided for @youHaveBeenEliminated.
  ///
  /// In en, this message translates to:
  /// **'You have been eliminated'**
  String get youHaveBeenEliminated;

  /// No description provided for @pressLeaveGameToExit.
  ///
  /// In en, this message translates to:
  /// **'Press \"Leave Game\" to exit'**
  String get pressLeaveGameToExit;

  /// No description provided for @spectatingPressJoinGame.
  ///
  /// In en, this message translates to:
  /// **'You are spectating. Press \"Join Game\" to play again.'**
  String get spectatingPressJoinGame;

  /// No description provided for @preparingNextRound.
  ///
  /// In en, this message translates to:
  /// **'Preparing next round'**
  String get preparingNextRound;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait'**
  String get pleaseWait;

  /// No description provided for @elimination.
  ///
  /// In en, this message translates to:
  /// **'Elimination'**
  String get elimination;

  /// No description provided for @playToWin.
  ///
  /// In en, this message translates to:
  /// **'Play To Win'**
  String get playToWin;

  /// No description provided for @offlineLobby.
  ///
  /// In en, this message translates to:
  /// **'Offline Lobby'**
  String get offlineLobby;

  /// No description provided for @quitGame.
  ///
  /// In en, this message translates to:
  /// **'Quit Game'**
  String get quitGame;

  /// No description provided for @confirmLeaveMatch.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the match?'**
  String get confirmLeaveMatch;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @drewAndSkipped.
  ///
  /// In en, this message translates to:
  /// **'Drew & Skipped'**
  String get drewAndSkipped;

  /// No description provided for @drew.
  ///
  /// In en, this message translates to:
  /// **'Drew'**
  String get drew;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @cardNotPlayable.
  ///
  /// In en, this message translates to:
  /// **'Card not playable'**
  String get cardNotPlayable;

  /// No description provided for @rewardsSharedByScoreRatio.
  ///
  /// In en, this message translates to:
  /// **'Rewards shared by score ratio'**
  String get rewardsSharedByScoreRatio;

  /// No description provided for @finalScoreboard.
  ///
  /// In en, this message translates to:
  /// **'Final Scoreboard'**
  String get finalScoreboard;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations'**
  String get congratulations;

  /// No description provided for @backToLobby.
  ///
  /// In en, this message translates to:
  /// **'Back to Lobby'**
  String get backToLobby;

  /// No description provided for @playing.
  ///
  /// In en, this message translates to:
  /// **'Playing'**
  String get playing;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @emojiAnimations.
  ///
  /// In en, this message translates to:
  /// **'Emoji Animations'**
  String get emojiAnimations;

  /// No description provided for @buttonSounds.
  ///
  /// In en, this message translates to:
  /// **'Button Sounds'**
  String get buttonSounds;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @backgroundMusic.
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @aboutAndSupport.
  ///
  /// In en, this message translates to:
  /// **'About & Support'**
  String get aboutAndSupport;

  /// No description provided for @gameInstructions.
  ///
  /// In en, this message translates to:
  /// **'Game Instructions'**
  String get gameInstructions;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'es', 'fr', 'zgh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'zgh': return AppLocalizationsZgh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
