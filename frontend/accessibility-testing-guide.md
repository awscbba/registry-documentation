# Browser Accessibility Testing Guide

## Overview

This guide provides instructions for testing the People Registry frontend application for WCAG 2.1 AA compliance using browser-based accessibility tools.

**Created**: 2025-12-04  
**Status**: Active  
**Related Spec**: `.kiro/specs/frontend-architecture-refactor/`

---

## Testing Tools

### 1. Manual Testing Checklist (Recommended for Quick Tests)

**Location**: `registry-frontend/scripts/test-accessibility-simple.html`

**How to Use**:
1. Open the HTML file in your browser
2. Follow the checklist to manually verify accessibility requirements
3. Use browser DevTools to run automated scans
4. Document findings in the notes section
5. Export results as JSON

**Features**:
- ✅ Comprehensive checklist covering WCAG 2.1 AA requirements
- ✅ Auto-saves progress to localStorage
- ✅ Export results as JSON
- ✅ Integrated instructions for browser DevTools
- ✅ Component-specific test cases

**Best For**:
- Quick manual verification
- Component-level testing
- Developer self-checks
- Documentation of manual tests

---

### 2. Automated Testing Script (Requires Setup)

**Location**: `registry-frontend/scripts/test-accessibility.js`

**Prerequisites**:
```bash
cd registry-frontend
npm install --save-dev playwright @axe-core/playwright @playwright/test
npx playwright install chromium
```

**How to Use**:
```bash
# Start the development server
npm run dev

# In another terminal, run the accessibility tests
node scripts/test-accessibility.js

# Or test a specific URL
node scripts/test-accessibility.js --url=http://localhost:4321
```

**Features**:
- ✅ Automated axe-core accessibility scanning
- ✅ Tests multiple pages automatically
- ✅ Keyboard navigation verification
- ✅ Focus indicator checks
- ✅ ARIA attribute validation
- ✅ Generates detailed JSON reports
- ✅ Exit code indicates pass/fail

**Best For**:
- CI/CD integration
- Comprehensive automated testing
- Regression testing
- Batch testing multiple pages

---

## Browser DevTools Testing

### Chrome Lighthouse

1. **Open DevTools**: Press `F12` or `Cmd+Option+I` (Mac)
2. **Navigate to Lighthouse tab**
3. **Configure**:
   - Select "Accessibility" category
   - Choose "Desktop" or "Mobile"
   - Click "Analyze page load"
4. **Review Results**:
   - Target score: 90+ (ideally 100)
   - Fix critical and serious issues first
   - Review detailed recommendations

**Lighthouse Checks**:
- Color contrast
- ARIA attributes
- Form labels
- Image alt text
- Heading hierarchy
- Keyboard navigation

---

### Firefox Accessibility Inspector

1. **Open DevTools**: Press `F12` or `Cmd+Option+I` (Mac)
2. **Navigate to Accessibility tab**
3. **Enable accessibility features**
4. **Check for issues**:
   - Contrast issues
   - Keyboard navigation
   - Text labels
   - Semantic structure
5. **Use Accessibility Tree**:
   - Verify proper ARIA roles
   - Check accessible names
   - Validate relationships

**Firefox Advantages**:
- Real-time contrast checking
- Accessibility tree visualization
- Keyboard navigation simulation
- Screen reader preview

---

### axe DevTools Extension

**Installation**:
- Chrome: [axe DevTools Extension](https://chrome.google.com/webstore/detail/axe-devtools-web-accessib/lhdoppojpmngadmnindnejefpokejbdd)
- Firefox: [axe DevTools Extension](https://addons.mozilla.org/en-US/firefox/addon/axe-devtools/)

**How to Use**:
1. Install the extension
2. Open DevTools (F12)
3. Navigate to "axe DevTools" tab
4. Click "Scan ALL of my page"
5. Review violations by severity:
   - **Critical**: Must fix immediately
   - **Serious**: Should fix before release
   - **Moderate**: Fix when possible
   - **Minor**: Nice to have

**axe DevTools Features**:
- Industry-standard accessibility testing
- Detailed violation descriptions
- Code snippets showing issues
- Remediation guidance
- Export reports

---

## WCAG 2.1 AA Requirements

### Color Contrast

**Requirements**:
- Normal text: 4.5:1 minimum
- Large text (18pt+ or 14pt+ bold): 3:1 minimum
- UI components and graphics: 3:1 minimum

**Tools**:
- Chrome DevTools Color Picker (shows contrast ratio)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)

**How to Check**:
1. Inspect element in DevTools
2. Click color swatch in Styles panel
3. View contrast ratio in color picker
4. Adjust colors if ratio is insufficient

---

### Keyboard Navigation

**Requirements**:
- All interactive elements accessible via Tab
- Logical tab order
- Enter activates buttons/links
- Escape closes modals/dropdowns
- Arrow keys navigate menus (where applicable)
- No keyboard traps

**How to Test**:
1. Close mouse/trackpad (or don't use it)
2. Use Tab to navigate through page
3. Use Enter to activate elements
4. Use Escape to close modals
5. Verify all functionality is accessible

**Common Issues**:
- Missing `tabindex` on custom controls
- Illogical tab order
- Keyboard traps in modals
- Missing keyboard event handlers

---

### Focus Indicators

**Requirements**:
- All focusable elements have visible focus indicator
- Focus indicator has 3:1 contrast ratio minimum
- Focus indicator is not removed with CSS

**How to Test**:
1. Tab through all interactive elements
2. Verify focus indicator is visible
3. Check contrast of focus indicator
4. Ensure custom focus styles are clear

**Common Issues**:
- `outline: none` without replacement
- Insufficient contrast on focus styles
- Focus indicator hidden by other elements

---

### ARIA Attributes

**Requirements**:
- Modals have `role="dialog"` and `aria-modal="true"`
- Modals have `aria-labelledby` or `aria-label`
- Buttons without text have `aria-label`
- Form inputs have labels or `aria-label`
- Dynamic content has `aria-live` regions
- Dropdown buttons have `aria-expanded`

**How to Test**:
1. Inspect elements in DevTools
2. Check for required ARIA attributes
3. Verify attribute values are correct
4. Test with screen reader

**Common Issues**:
- Missing ARIA labels on icon buttons
- Incorrect ARIA roles
- Missing `aria-expanded` on dropdowns
- No `aria-live` for dynamic content

---

### Focus Management

**Requirements**:
- Focus moves to modal when opened
- Focus returns to trigger when modal closes
- Focus is trapped within modal
- Focus moves to error messages after validation

**How to Test**:
1. Open modal with keyboard
2. Verify focus is in modal
3. Close modal with Escape
4. Verify focus returns to trigger
5. Try to Tab outside modal (should not be possible)

**Common Issues**:
- Focus not moved to modal
- Focus not returned after close
- Focus not trapped in modal
- Focus lost after form submission

---

## Screen Reader Testing

### VoiceOver (Mac)

**Enable**: `Cmd + F5`

**Basic Commands**:
- `VO + Right Arrow`: Next element
- `VO + Left Arrow`: Previous element
- `VO + Space`: Activate element
- `VO + A`: Read all
- `VO + U`: Open rotor (navigation menu)

**What to Test**:
- All content is announced
- Headings are properly identified
- Links are descriptive
- Form labels are associated
- Dynamic content changes are announced
- Error messages are announced

---

### NVDA (Windows)

**Download**: [NVDA Screen Reader](https://www.nvaccess.org/download/)

**Basic Commands**:
- `Down Arrow`: Next element
- `Up Arrow`: Previous element
- `Enter`: Activate element
- `Insert + Down Arrow`: Read all
- `Insert + F7`: Elements list

**What to Test**:
- Same as VoiceOver testing
- Verify Windows-specific behavior
- Test with different browsers

---

## Component-Specific Tests

### AuthContext & useAuth

**Test**:
- Login/logout actions are announced
- Authentication state changes are communicated
- Error messages are accessible

**How**:
1. Use screen reader
2. Attempt login
3. Verify success/error is announced
4. Logout and verify announcement

---

### ToastContext & ToastContainer

**Test**:
- Toast notifications are announced
- Toasts have `aria-live="polite"`
- Toasts have `role="alert"`
- Close button has `aria-label`

**How**:
1. Trigger toast notification
2. Verify screen reader announces it
3. Tab to close button
4. Verify button has accessible name

---

### UserLoginModal

**Test**:
- Modal has proper ARIA attributes
- Focus moves to modal on open
- Focus returns on close
- Form validation errors are announced
- Keyboard navigation works

**How**:
1. Open modal with keyboard
2. Verify focus management
3. Fill form with keyboard
4. Submit and verify error handling
5. Close with Escape key

---

### ProjectShowcase

**Test**:
- All project cards are keyboard accessible
- Subscribe buttons have clear labels
- Pagination is keyboard accessible
- View mode controls are accessible

**How**:
1. Tab through all project cards
2. Activate subscribe button with Enter
3. Navigate pagination with keyboard
4. Switch view modes with keyboard

---

### ErrorBoundary

**Test**:
- Error message is announced
- Reload button is keyboard accessible
- Error has proper semantic markup

**How**:
1. Trigger error (if possible)
2. Verify error message is announced
3. Tab to reload button
4. Activate with Enter

---

## Testing Workflow

### 1. Pre-Development

- Review WCAG 2.1 AA requirements
- Plan accessible component structure
- Choose appropriate ARIA attributes

### 2. During Development

- Use manual checklist for quick checks
- Test with keyboard navigation
- Verify focus indicators
- Check color contrast

### 3. Before Commit

- Run automated accessibility script
- Fix critical and serious issues
- Document any known issues
- Update accessibility documentation

### 4. Before Release

- Full manual testing with checklist
- Screen reader testing (VoiceOver/NVDA)
- Cross-browser testing
- Generate accessibility report

---

## Common Issues and Solutions

### Issue: Low Contrast

**Solution**:
```css
/* Before */
color: #999; /* 2.8:1 - FAIL */

/* After */
color: #666; /* 5.7:1 - PASS */
```

---

### Issue: Missing Focus Indicator

**Solution**:
```css
/* Before */
button:focus {
  outline: none; /* BAD */
}

/* After */
button:focus {
  outline: 3px solid #2196F3;
  outline-offset: 2px;
}
```

---

### Issue: Button Without Label

**Solution**:
```tsx
{/* Before */}
<button onClick={handleClose}>×</button>

{/* After */}
<button onClick={handleClose} aria-label="Close modal">
  ×
</button>
```

---

### Issue: Modal Without ARIA

**Solution**:
```tsx
{/* Before */}
<div className="modal">
  <h2>Login</h2>
  {/* content */}
</div>

{/* After */}
<div 
  className="modal"
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
>
  <h2 id="modal-title">Login</h2>
  {/* content */}
</div>
```

---

### Issue: Form Input Without Label

**Solution**:
```tsx
{/* Before */}
<input type="email" placeholder="Email" />

{/* After */}
<label htmlFor="email">Email</label>
<input type="email" id="email" placeholder="Email" />

{/* Or with aria-label */}
<input type="email" aria-label="Email address" placeholder="Email" />
```

---

## Accessibility Report Template

```markdown
# Accessibility Test Report

**Date**: YYYY-MM-DD
**Tester**: [Name]
**Pages Tested**: [List pages]
**Tools Used**: [List tools]

## Summary

- **Total Issues**: X
- **Critical**: X
- **Serious**: X
- **Moderate**: X
- **Minor**: X

## WCAG 2.1 AA Compliance

- [ ] Color Contrast: PASS/FAIL
- [ ] Keyboard Navigation: PASS/FAIL
- [ ] Focus Indicators: PASS/FAIL
- [ ] ARIA Attributes: PASS/FAIL
- [ ] Focus Management: PASS/FAIL
- [ ] Screen Reader: PASS/FAIL

## Issues Found

### Critical Issues

1. **Issue**: [Description]
   - **Location**: [Component/Page]
   - **Impact**: [User impact]
   - **Solution**: [How to fix]

### Serious Issues

[Same format as critical]

## Recommendations

[List recommendations for improvement]

## Next Steps

[List action items]
```

---

## Resources

### Official Guidelines

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WAI-ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)
- [MDN Accessibility](https://developer.mozilla.org/en-US/docs/Web/Accessibility)

### Testing Tools

- [axe DevTools](https://www.deque.com/axe/devtools/)
- [WAVE Browser Extension](https://wave.webaim.org/extension/)
- [Lighthouse](https://developers.google.com/web/tools/lighthouse)
- [Pa11y](https://pa11y.org/)

### Color Contrast

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)
- [Contrast Ratio Calculator](https://contrast-ratio.com/)

### Screen Readers

- [NVDA (Windows)](https://www.nvaccess.org/)
- [JAWS (Windows)](https://www.freedomscientific.com/products/software/jaws/)
- [VoiceOver (Mac/iOS)](https://www.apple.com/accessibility/voiceover/)
- [TalkBack (Android)](https://support.google.com/accessibility/android/answer/6283677)

---

## Continuous Improvement

### Regular Testing Schedule

- **Daily**: Quick manual checks during development
- **Weekly**: Automated script runs
- **Before Release**: Full manual + screen reader testing
- **Quarterly**: Comprehensive accessibility audit

### Team Training

- Regular accessibility workshops
- Share accessibility best practices
- Review accessibility issues in code reviews
- Celebrate accessibility improvements

### Documentation

- Keep this guide updated
- Document new patterns and solutions
- Share lessons learned
- Maintain accessibility checklist

---

## Support

For questions or issues with accessibility testing:

1. Review this guide
2. Check WCAG 2.1 documentation
3. Consult with accessibility specialist
4. File issue in project tracker

---

**Last Updated**: 2025-12-04  
**Maintained By**: Frontend Team  
**Review Frequency**: Quarterly
