# Upgrade to Silverstripe CMS 6

## Dependencies

⚠️ **BREAKING CHANGE**: Update Composer dependencies to Silverstripe 6 compatible versions.

Update your `composer.json`:

```json
"require": {
  "silverstripe/framework": "^6.0",
  "silverstripe/admin": "^3.0"
},
"require-dev": {
  "sunnysideup/sswebpack_engine_only": "^5.0-dev"
}
```

Run `composer update` after making these changes.

---

**🚨 CRITICAL REVIEW REQUIRED**

**This diff only shows dependency version changes. A real Silverstripe 5→6 upgrade typically requires additional code changes including:**
- **Namespace updates**
- **API method signature changes** 
- **Template syntax updates**
- **Configuration schema changes**
- **Removed/deprecated API usage**

**Review your entire codebase for Silverstripe 6 compatibility beyond these Composer changes.**
