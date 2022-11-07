package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin;
import com.mr.flutter.plugin.filepicker.FilePickerPlugin;
import io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin;
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin;
import io.flutter.plugins.firebase.storage.FirebaseStoragePlugin;
import com.example.flutterimagecompress.FlutterImageCompressPlugin;
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;
import io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin;
import io.flutter.plugins.googlesignin.GoogleSignInPlugin;
import com.lykhonis.imagecrop.ImageCropPlugin;
import adhoc.successive.com.fluttergallaryplugin.FlutterGallaryPlugin;
import io.flutter.plugins.imagepicker.ImagePickerPlugin;
import com.example.media_gallery.MediaGalleryPlugin;
import io.flutter.plugins.pathprovider.PathProviderPlugin;
import top.kikt.imagescanner.ImageScannerPlugin;
import com.tekartik.sqflite.SqflitePlugin;
import com.follow2vivek.storagepath.StoragePathPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterFirebaseFirestorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin"));
    FilePickerPlugin.registerWith(registry.registrarFor("com.mr.flutter.plugin.filepicker.FilePickerPlugin"));
    FlutterFirebaseAuthPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin"));
    FlutterFirebaseCorePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"));
    FirebaseStoragePlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebase.storage.FirebaseStoragePlugin"));
    FlutterImageCompressPlugin.registerWith(registry.registrarFor("com.example.flutterimagecompress.FlutterImageCompressPlugin"));
    FlutterAndroidLifecyclePlugin.registerWith(registry.registrarFor("io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
    FlutterToastPlugin.registerWith(registry.registrarFor("io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin"));
    GoogleSignInPlugin.registerWith(registry.registrarFor("io.flutter.plugins.googlesignin.GoogleSignInPlugin"));
    ImageCropPlugin.registerWith(registry.registrarFor("com.lykhonis.imagecrop.ImageCropPlugin"));
    FlutterGallaryPlugin.registerWith(registry.registrarFor("adhoc.successive.com.fluttergallaryplugin.FlutterGallaryPlugin"));
    ImagePickerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.imagepicker.ImagePickerPlugin"));
    MediaGalleryPlugin.registerWith(registry.registrarFor("com.example.media_gallery.MediaGalleryPlugin"));
    PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider.PathProviderPlugin"));
    ImageScannerPlugin.registerWith(registry.registrarFor("top.kikt.imagescanner.ImageScannerPlugin"));
    SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"));
    StoragePathPlugin.registerWith(registry.registrarFor("com.follow2vivek.storagepath.StoragePathPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
