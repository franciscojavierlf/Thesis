class Profile {
  /// The id of the profile.
  final String id;
  /// The name of the user.
  final String name;
  /// The wallet in the blockchain.
  final String walletId;

  Profile({
    required this.id,
    required this.name,
    required this.walletId,
  });
}
