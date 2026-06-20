import 'package:flutter_test/flutter_test.dart';
import 'package:air_charters/shared/utils/session_manager.dart';
import 'package:air_charters/core/models/auth_model.dart';

void main() {
  group('SessionManager.refreshTokenOnce', () {
    test('concurrent refresh calls share one refresh', () async {
      final sm = SessionManager();

      int called = 0;
      sm.setRefreshHandlerForTesting((String token) async {
        called += 1;
        await Future.delayed(Duration(milliseconds: 100));
        return AuthModel(
          accessToken: 'a',
          refreshToken: 'r',
          tokenType: 'Bearer',
          expiresIn: 3600,
          expiresAt: DateTime.now().add(Duration(hours: 1)),
          user: UserModel(id: 'u', firstName: 'T', lastName: 'U', email: 't@u.com'),
        );
      });

      final results = await Future.wait([
        sm.refreshTokenOnce(),
        sm.refreshTokenOnce(),
        sm.refreshTokenOnce(),
      ]);

      expect(called, equals(1));
      expect(results.where((r) => r != null).length, equals(3));
    });

    test('refresh failure clears auth', () async {
      final sm = SessionManager();

      sm.setRefreshHandlerForTesting((String token) async {
        return null; // simulate failure
      });

      final res = await sm.refreshTokenOnce();
      expect(res, isNull);
    });
  });
}
