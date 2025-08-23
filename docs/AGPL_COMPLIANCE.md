# AGPL-3.0 License Compliance Guide

## Overview

The Spatial Mempool VisionOS project is a derivative work of the Mempool Open Source Project® and must comply with the GNU Affero General Public License version 3.0 (AGPL-3.0).

## License Requirements

### 1. Source Code Availability

**Requirement**: Any network-accessible deployment must provide source code access.

**Implementation**:
- Source code is available at: https://github.com/jeffmarcilliat/mempool
- All modifications and enhancements are published under AGPL-3.0
- Self-hosted deployments must provide source code access to users

**For Self-Hosted Deployments**:
```bash
# Add source code link to your deployment
# In your mempool backend configuration:
AGPL_SOURCE_URL="https://github.com/jeffmarcilliat/mempool"
AGPL_COMPLIANCE_NOTICE="Source code available under AGPL-3.0"
```

### 2. License Notice Requirements

**Requirement**: Include license notices in all source files and distributions.

**Implementation**:
- LICENSE file included in repository root
- Copyright notices in source files
- Attribution to upstream Mempool project
- License information in app about screen

**VisionOS App License Notice**:
```swift
// Add to app's About/Settings screen
let licenseNotice = """
Spatial Mempool VisionOS
Copyright (c) 2025 Jeffrey Marcilliat

Based on The Mempool Open Source Project®
Copyright (c) 2019-2025 Mempool Space K.K.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Source code: https://github.com/jeffmarcilliat/mempool
"""
```

### 3. Attribution Requirements

**Requirement**: Proper attribution to upstream Mempool project.

**Implementation**:

#### In App Interface
- About screen with attribution to Mempool Open Source Project®
- Link to original mempool.space project
- Clear indication this is a derivative work

#### In Documentation
- README.md includes attribution section
- ARCHITECTURE.md references upstream project
- All documentation acknowledges original work

#### In Source Code
```swift
/*
 * Spatial Mempool VisionOS
 * Based on The Mempool Open Source Project®
 * Original work: https://github.com/mempool/mempool
 * 
 * This file is part of a derivative work licensed under AGPL-3.0
 */
```

### 4. Trademark Compliance

**Requirement**: Respect Mempool trademarks while maintaining compliance.

**Restrictions**:
- Cannot use "Mempool®" trademark in app name
- Cannot use official Mempool logos without permission
- Must clearly indicate this is a derivative/unofficial work

**Implementation**:
- App name: "Spatial Mempool" (not "Mempool VisionOS")
- Custom iconography and branding
- Clear disclaimer about unofficial status
- Attribution to trademark holders

### 5. Network Service Compliance

**Requirement**: AGPL-3.0 Section 13 - Network interaction compliance.

**For Public Deployments**:
```swift
// Add to API responses
struct AGPLCompliance {
    let sourceCodeURL = "https://github.com/jeffmarcilliat/mempool"
    let licenseURL = "https://www.gnu.org/licenses/agpl-3.0.html"
    let notice = "This service uses AGPL-3.0 licensed software. Source code available."
}
```

**For Self-Hosted Deployments**:
- Include source code access information in web interface
- Provide download link for complete source code
- Ensure users can access modifications and enhancements

## Implementation Checklist

### ✅ Repository Level
- [x] LICENSE file with AGPL-3.0 text
- [x] COPYRIGHT notices in key files
- [x] README attribution section
- [x] Source code availability documentation

### 🔄 Application Level
- [ ] About screen with license information
- [ ] Attribution to upstream Mempool project
- [ ] Source code access link in app
- [ ] Trademark compliance verification

### 🔄 Distribution Level
- [ ] TestFlight/App Store compliance review
- [ ] Enterprise distribution license notices
- [ ] Self-hosting deployment guides
- [ ] Source code access automation

### 🔄 Documentation Level
- [ ] License compliance in all docs
- [ ] Attribution in technical documentation
- [ ] Trademark usage guidelines
- [ ] Compliance verification procedures

## Compliance Verification

### Automated Checks
```bash
# Check for license headers in source files
find . -name "*.swift" -exec grep -L "AGPL\|GNU Affero" {} \;

# Verify LICENSE file exists and is correct
test -f LICENSE && grep -q "GNU AFFERO GENERAL PUBLIC LICENSE" LICENSE

# Check for attribution in README
grep -q "Mempool Open Source Project" README.md
```

### Manual Review
1. **Source Code Review**: Ensure all new files have appropriate headers
2. **App Interface Review**: Verify license information is accessible to users
3. **Distribution Review**: Check that all distribution methods include license
4. **Attribution Review**: Confirm proper credit to upstream project

## Risk Mitigation

### High Risk Areas
1. **App Store Distribution**: Ensure Apple's terms don't conflict with AGPL
2. **Enterprise Distribution**: Verify compliance in closed environments
3. **Trademark Usage**: Avoid unauthorized use of Mempool trademarks
4. **Source Code Access**: Ensure reliable access to complete source

### Mitigation Strategies
1. **Legal Review**: Consult legal counsel for distribution strategies
2. **Automated Compliance**: Build compliance checks into CI/CD
3. **Documentation**: Maintain clear compliance documentation
4. **Community Engagement**: Engage with upstream project maintainers

## Contact and Resources

### Legal Resources
- **AGPL-3.0 Full Text**: https://www.gnu.org/licenses/agpl-3.0.html
- **FSF AGPL Guide**: https://www.gnu.org/licenses/agpl-3.0-faq.html
- **Copyleft Guide**: https://copyleft.org/guide/

### Upstream Project
- **Mempool Project**: https://github.com/mempool/mempool
- **Mempool Website**: https://mempool.space
- **Trademark Policy**: https://mempool.space/trademark-policy

### This Project
- **Source Repository**: https://github.com/jeffmarcilliat/mempool
- **Issue Tracker**: https://github.com/jeffmarcilliat/mempool/issues
- **License Questions**: Create issue with "license" label

## Updates and Maintenance

### Regular Reviews
- **Quarterly**: Review compliance with any new features
- **Before Releases**: Verify all compliance requirements met
- **Annual**: Full compliance audit and documentation update

### Change Management
- **New Features**: Assess AGPL compliance impact
- **Dependencies**: Verify license compatibility
- **Distribution Changes**: Review compliance implications

---

**Last Updated**: August 23, 2025  
**Version**: 1.0  
**Compliance Status**: In Progress  
**Next Review**: Gate 1 Completion
