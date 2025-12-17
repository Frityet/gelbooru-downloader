#include "Path.h"

#include "utilities/OFArray+Functional.h"

Optional<OFArray<OFIRI *> *> *getPathEnvironmentVariableEntries(void)
{
    auto p = OFApplication.sharedApplication.environment[@"PATH"];
    if (not p) return Optional.none;
    return [Optional some: [[$assert_nonnil(p) componentsSeparatedByString: @":"] map: ^nonnil id (OFString *object) {
        return [OFIRI fileIRIWithPath: object isDirectory: true];
    }]];
}
