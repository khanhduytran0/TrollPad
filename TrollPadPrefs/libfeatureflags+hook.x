#import <string.h>

bool _os_feature_enabled_impl(const char *domain, const char *feature);
%hookf(bool, _os_feature_enabled_impl, const char *domain, const char *feature) {
    if (!strcmp(domain, "Ensemble") && !strcmp(feature, "Enabled")) {
        return true;
    }
    return %orig;
}
