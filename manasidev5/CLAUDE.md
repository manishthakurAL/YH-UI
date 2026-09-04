# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Salesforce DX source for Yorkshire Housing's Experience Cloud sites — a customer self-service portal built on the **Customer Account Portal** template with an **Aura** theme layout. Two networks/sites live in this one org: `YH Customer Portal` (authenticated, experience bundle `YH_Customer_Portal1`) and `YH Guest Support Portal` (unauthenticated). Ignore `test1`/`test12`/`test121` — throwaway scratch sites, not real targets.

Default org alias is `manasidev5` (`.sf/config.json`). API version `67.0` (`sfdx-project.json`).

`Brand_Guidelines.pdf` at the repo root is the source of truth for any UI/styling work — palette (YH Purple `#34215a`, YH Rose `#f04d6e`, YH Yellow `#f9ab23`, YH Green `#4fc3ae`, each with an official tone-on-tone tint/shade ramp), typography (Source Sans Pro for portal/colleague content, FS Elliot reserved for design/marketing headlines), and hard rules like "never use type in all caps" and "logo never aligned to the right." Check it before introducing new colors or hardcoded hex values.

## Commands

```bash
# Deploy / retrieve metadata
sf project deploy start --source-dir force-app/main/default/lwc/<component> --target-org manasidev5
sf project retrieve start --source-dir force-app/main/default/classes/<Class>.cls --target-org manasidev5

# LWC unit tests (Jest)
npm run test:unit                                   # all LWC tests
npx sfdx-lwc-jest force-app/main/default/lwc/<component>   # single component
npm run test:unit:watch
npm run test:unit:coverage

# Apex tests
sf apex run test --tests <ClassName> --target-org manasidev5 --result-format human --wait 10
sf apex run test --class-names <ClassName> --code-coverage --target-org manasidev5

# Lint / format
npm run lint             # eslint over aura + lwc JS
npm run prettier         # write formatting (cls/cmp/css/html/js/json/xml/...)
npm run prettier:verify  # check only
```

`husky` runs `lint-staged` on commit (prettier on all matching files, eslint on `aura`/`lwc` JS, `sfdx-lwc-jest --bail --findRelatedTests` on LWC changes) — expect these to run automatically on `git commit`.

## Architecture

**Aura shell + LWC content.** The site's theme layout (header, sidebar, nav) is the Aura component `customPortalTheme` (`aura/customPortalTheme`, implements `forceCommunity:themeLayout`, controller `CustomPortalThemeController.cls`), driven by a Navigation Menu (`YH_Portal_Navigation_Menu`). Aura is otherwise only used for the outer app wrapper (`YH_CustomerPortal`) and auth-flow pages (`loginForm`, `forgotPassword`, `selfRegister`, `setExpId`, `setStartUrl`). All actual page/feature content is LWC (`force-app/main/default/lwc`), exposed to the site via `lightningCommunity__Page` / `lightningCommunity__Default` targets in each component's `*.js-meta.xml`. When adding a new page-level feature, build it as LWC, not Aura.

**Trigger logic is metadata-driven, not per-object handlers.** Every `.trigger` file is a one-liner: `new MetadataTriggerHandler().run();` (the open-source Trigger Actions Framework). Actual logic lives in classes implementing `TriggerAction.BeforeInsert` / `AfterInsert` / `BeforeUpdate` / etc., registered against an SObject+context via `Trigger_Action__mdt` custom metadata records (with `Order__c` sequencing and `Bypass_Permission__c`/`Bypass_Execution__c` support). To add trigger behavior: create a class implementing the relevant `TriggerAction.*` interface and register a `Trigger_Action__mdt` record — never add logic directly to a `.trigger` file or wire up a new handler class by hand.

**Data-access and constants layers**, consistent across ~640 Apex classes:
- `Uth<SObject>` classes (`UthCase`, `UthUser`, `UthProfile`, `UthTenancy`, …) — query/selector helpers for that SObject. Check for an existing `Uth*` method before writing a new SOQL query inline.
- `<SObject>Decorator` classes (`CaseDecorator`, `UserDecorator`, …) — hold constants such as status/picklist values, profile names, record type developer names. Check the relevant Decorator before hardcoding a literal like a profile name or status string.

**Apex test users are built, not queried.** Use `UthUser.buildUser(roleId, profileId, firstName, lastName)` (auto-generates unique username/email/alias) plus `UthProfile.getProfileUsingName(name)` / `UserDecorator.PROFILE_*` constants to construct and `insert` a test user, rather than querying for a pre-existing org user — org-dependent user lookups make tests fragile across sandboxes.

**User-facing text goes through Custom Labels**, not hardcoded strings — `force-app/main/default/labels/CustomLabels.labels-meta.xml`, referenced in LWC as `@salesforce/label/c.<LabelName>`.

**Experience Cloud config beyond Apex/LWC** lives in `force-app/main/default/digitalExperiences/site/<siteName>/` (CMS-managed routes, theme, branding sets, language settings) and `force-app/main/default/networks/*.network-meta.xml` (per-site network settings) — these are edited via Experience Builder / Setup in the org and retrieved, not typically hand-authored.
