// lib/features/student/blocs/anonymous_issue_reporting/utils/anonymous_identity.dart
import 'package:flutter/material.dart';

/// Generates deterministic-but-untraceable "Anonymous X" labels and avatar
/// colors from a seed string, so the same person appears consistently
/// *within one thread* without ever exposing their real identity, and
/// without letting anyone correlate their identity *across* different
/// posts (each post gets its own independent seed).
///
/// IMPORTANT: this class never stores or derives anything from a real
/// name/email/roll number. It only ever hashes opaque doc IDs.
class AnonymousIdentity {
  AnonymousIdentity._();

  static const List<String> _adjectives = [
    'Curious', 'Quiet', 'Bold', 'Gentle', 'Swift', 'Clever', 'Calm',
    'Brave', 'Witty', 'Silent', 'Sharp', 'Kind', 'Lively', 'Humble',
    'Mysterious', 'Cheerful', 'Steady', 'Nimble', 'Wise', 'Playful',
  ];

  static const List<String> _nouns = [
    'Falcon', 'Otter', 'Panda', 'Fox', 'Owl', 'Tiger', 'Sparrow',
    'Dolphin', 'Wolf', 'Rabbit', 'Hawk', 'Koala', 'Lynx', 'Heron',
    'Badger', 'Raven', 'Panther', 'Squirrel', 'Falcon', 'Ibis',
  ];

  static const List<Color> _palette = [
    Color(0xFF29B6F6), // sky blue
    Color(0xFF26A69A), // teal
    Color(0xFFEF5350), // red
    Color(0xFFAB47BC), // purple
    Color(0xFFFFA726), // orange
    Color(0xFF66BB6A), // green
    Color(0xFF5C6BC0), // indigo
    Color(0xFFEC407A), // pink
  ];

  static int _hash(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

  /// e.g. "Anonymous Curious Falcon"
  static String labelFor(String seed) {
    final hash = _hash(seed);
    final adjective = _adjectives[hash % _adjectives.length];
    final noun = _nouns[(hash ~/ _adjectives.length) % _nouns.length];
    return 'Anonymous $adjective $noun';
  }

  static Color colorFor(String seed) {
    final hash = _hash(seed);
    return _palette[hash % _palette.length];
  }

  /// Seed for a post's author label: unique per post only (not linkable
  /// across a person's other posts).
  static String postSeed(String postId) => 'post::$postId';

  /// Seed for a commenter's label *within one post's thread*: consistent
  /// for the same author inside this post (so people can follow a
  /// conversation), but unrelated to their identity on any other post.
  static String commentSeed(String postId, String authorId) =>
      'comment::$postId::$authorId';
}
