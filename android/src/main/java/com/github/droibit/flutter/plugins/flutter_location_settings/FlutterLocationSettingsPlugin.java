package com.github.droibit.flutter.plugins.flutter_location_settings;

import android.app.Activity;
import android.content.Intent;
import android.content.IntentSender;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.common.api.ResolvableApiException;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResponse;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.location.SettingsClient;
import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;

/** FlutterLocationSettingsPlugin */
public class FlutterLocationSettingsPlugin
    implements MethodCallHandler, PluginRegistry.ActivityResultListener {

  public static int REQUEST_CODE_LOCATION_ENABLE = 482440;

  private static final String KEY_PRIORITY = "priority";
  private static final String KEY_ALWAYS_SHOW = "alwaysShow";
  private static final String KEY_NEED_BLE = "needBle";
  private static final String KEY_SHOW_DIALOG = "showDialog";

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(),
            "com.github.droibit.flutter.plugins.flutter_location_settings");
    channel.setMethodCallHandler(new FlutterLocationSettingsPlugin(registrar));
  }

  FlutterLocationSettingsPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.registrar.addActivityResultListener(this);
  }

  private final PluginRegistry.Registrar registrar;

  @Nullable
  private Result pendingResult;

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("checkLocationEnabled")) {
      final Map<String, Object> option = call.arguments();
      checkLocationEnabled(option, result);
    } else {
      result.notImplemented();
    }
  }

  @SuppressWarnings("ConstantConditions")
  private void checkLocationEnabled(@NonNull Map<String, Object> option,
      @NonNull final Result result) {
    final LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder();
    if (option.get(KEY_PRIORITY) != null) {
      builder.addLocationRequest(
          new LocationRequest().setPriority(((Integer) option.get(KEY_PRIORITY)))
      );
    }
    if (option.get(KEY_ALWAYS_SHOW) != null) {
      builder.setAlwaysShow(((Boolean) option.get(KEY_ALWAYS_SHOW)));
    }

    if (option.get(KEY_NEED_BLE) != null) {
      builder.setNeedBle(((Boolean) option.get(KEY_NEED_BLE)));
    }

    final boolean showDialog;
    if (option.get(KEY_SHOW_DIALOG) != null) {
      showDialog = ((Boolean) option.get(KEY_SHOW_DIALOG));
    } else {
      showDialog = false;
    }

    final SettingsClient settingsClient = LocationServices.getSettingsClient(registrar.context());
    settingsClient.checkLocationSettings(builder.build())
        .addOnCompleteListener(new OnCompleteListener<LocationSettingsResponse>() {
          @Override public void onComplete(@NonNull Task<LocationSettingsResponse> task) {
            try {
              task.getResult(ApiException.class);
              result.success(LocationSettingsStatusCodes.SUCCESS);
            } catch (ApiException e) {
              handleApiException(e, result, showDialog);
            }
          }
        });
  }

  private void handleApiException(
      @NonNull ApiException e,
      @NonNull final Result result,
      boolean showDialog
  ) {
    final int statusCode = e.getStatusCode();
    final Runnable callbackFailed = new Runnable() {
      @Override public void run() {
        FlutterLocationSettingsPlugin.this.pendingResult = null;
        result.success(statusCode);
      }
    };

    switch (statusCode) {
      case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
        if (showDialog) {
          try {
            final ResolvableApiException resolvable = (ResolvableApiException) e;
            resolvable.startResolutionForResult(
                registrar.activity(),
                REQUEST_CODE_LOCATION_ENABLE
            );
            pendingResult = result;
          } catch (IntentSender.SendIntentException | ClassCastException ignored) {
            callbackFailed.run();
          }
        } else {
          callbackFailed.run();
        }
        break;
      case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
        callbackFailed.run();
        break;
      default:
        callbackFailed.run();
        break;
    }
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent intent) {
    if (requestCode != REQUEST_CODE_LOCATION_ENABLE) {
      return false;
    }

    final Result pendingResult = this.pendingResult;
    if (pendingResult != null) {
      pendingResult.success(resultCode == Activity.RESULT_OK ? LocationSettingsStatusCodes.SUCCESS
          : LocationSettingsStatusCodes.CANCELED);
    }
    this.pendingResult = null;
    return true;
  }
}
