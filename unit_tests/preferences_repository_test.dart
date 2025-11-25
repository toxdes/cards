import 'package:cards/repositories/preferences_repository.dart';
import 'package:test/test.dart';

import 'mocks/mock_storage.dart';

void main() {
  test('save and read cycle preserves all preferences', () async {
    MockStorage storage = MockStorage();
    
    // Create and modify preferences
    PreferencesRepository repo1 = PreferencesRepository(
      storageKey: PreferencesStorageKeys.testStorage,
      storage: storage,
    );
    
    repo1.setMaskCardNumber(false);
    repo1.setMaskCVV(true);
    repo1.setEnableNotifications(false);
    repo1.setUseDeviceAuth(true);
    await repo1.save();
    
    // Load in a new repository
    PreferencesRepository repo2 = PreferencesRepository(
      storageKey: PreferencesStorageKeys.testStorage,
      storage: storage,
    );
    await repo2.readFromStorage();
    
    // Verify all preferences are preserved
    assert(repo2.prefs.maskCardNumber == repo1.prefs.maskCardNumber);
    assert(repo2.prefs.maskCVV == repo1.prefs.maskCVV);
    assert(repo2.prefs.enableNotifications == repo1.prefs.enableNotifications);
    assert(repo2.prefs.useDeviceAuth == repo1.prefs.useDeviceAuth);
  });

  test('readFromStorage handles empty storage gracefully', () async {
    MockStorage storage = MockStorage();
    PreferencesRepository repo = PreferencesRepository(
      storageKey: PreferencesStorageKeys.testStorage,
      storage: storage,
    );
    
    await repo.readFromStorage();
    // Should use defaults when storage is empty
    assert(repo.prefs.maskCardNumber == true);
    assert(repo.prefs.maskCVV == true);
    assert(repo.prefs.enableNotifications == true);
    assert(repo.prefs.useDeviceAuth == true);
  });

  test('clearStorage removes preferences from storage', () async {
    MockStorage storage = MockStorage();
    PreferencesRepository repo = PreferencesRepository(
      storageKey: PreferencesStorageKeys.testStorage,
      storage: storage,
    );
    
    repo.setMaskCardNumber(false);
    await repo.save();
    
    // Verify it was saved
    String? saved = await storage.read(key: PreferencesStorageKeys.testStorage);
    assert(saved != null);
    
    // Clear it
    repo.clearStorage();
    
    // Verify it's cleared
    String? cleared = await storage.read(key: PreferencesStorageKeys.testStorage);
    assert(cleared == null);
  });

  test('different storage keys isolate preferences', () async {
    MockStorage storage = MockStorage();
    
    PreferencesRepository repo1 = PreferencesRepository(
      storageKey: PreferencesStorageKeys.mainStorage,
      storage: storage,
    );
    repo1.setMaskCardNumber(false);
    await repo1.save();
    
    PreferencesRepository repo2 = PreferencesRepository(
      storageKey: PreferencesStorageKeys.testStorage,
      storage: storage,
    );
    await repo2.readFromStorage();
    
    // repo2 should have defaults, not repo1's changes
    assert(repo2.prefs.maskCardNumber == true);
  });

  test('multiple preference changes persist independently', () async {
    MockStorage storage = MockStorage();
    PreferencesRepository repo = PreferencesRepository(
      storageKey: PreferencesStorageKeys.testStorage,
      storage: storage,
    );
    
    repo.setMaskCardNumber(false);
    repo.setEnableNotifications(false);
    repo.setUseDeviceAuth(false);
    // maskCVV stays true
    
    await repo.save();
    
    PreferencesRepository repo2 = PreferencesRepository(
      storageKey: PreferencesStorageKeys.testStorage,
      storage: storage,
    );
    await repo2.readFromStorage();
    
    assert(repo2.prefs.maskCardNumber == false);
    assert(repo2.prefs.maskCVV == true);
    assert(repo2.prefs.enableNotifications == false);
    assert(repo2.prefs.useDeviceAuth == false);
  });
}
