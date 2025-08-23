# Design Tokens - Spatial Mempool VisionOS

## Overview

This document defines the design system tokens for the Spatial Mempool VisionOS application, ensuring consistent visual design and user experience across all components.

## Color System

### Primary Colors

#### Bitcoin Orange
- **Primary**: `#F7931A` (Bitcoin brand orange)
- **Primary Light**: `#FF9F2E` (hover states, highlights)
- **Primary Dark**: `#E8851A` (pressed states, shadows)
- **Primary Ultra Light**: `#FFF4E6` (backgrounds, subtle accents)

#### Blockchain Blue
- **Secondary**: `#0066CC` (blockchain data, links)
- **Secondary Light**: `#3385D6` (hover states)
- **Secondary Dark**: `#004499` (pressed states)
- **Secondary Ultra Light**: `#E6F2FF` (backgrounds)

#### Mempool Green
- **Success**: `#00C851` (confirmed transactions, success states)
- **Success Light**: `#33D470` (hover states)
- **Success Dark**: `#00A043` (pressed states)
- **Success Ultra Light**: `#E6F9ED` (backgrounds)

#### Fee Red
- **Warning**: `#FF4444` (high fees, urgent states)
- **Warning Light**: `#FF6666` (hover states)
- **Warning Dark**: `#CC0000` (pressed states)
- **Warning Ultra Light**: `#FFE6E6` (backgrounds)

### Neutral Colors

#### Spatial Grays
- **Gray 900**: `#1A1A1A` (primary text, high contrast)
- **Gray 800**: `#2D2D2D` (secondary text)
- **Gray 700**: `#404040` (tertiary text)
- **Gray 600**: `#666666` (disabled text)
- **Gray 500**: `#808080` (borders, dividers)
- **Gray 400**: `#999999` (placeholder text)
- **Gray 300**: `#CCCCCC` (light borders)
- **Gray 200**: `#E6E6E6` (light backgrounds)
- **Gray 100**: `#F5F5F5` (subtle backgrounds)
- **Gray 50**: `#FAFAFA` (lightest backgrounds)

#### Spatial Whites
- **White**: `#FFFFFF` (pure white, cards, modals)
- **Off White**: `#FDFDFD` (main backgrounds)
- **Warm White**: `#FFFEF9` (warm backgrounds)

### 3D Material Colors

#### Block Materials
- **Confirmed Block**: `rgba(0, 102, 204, 0.8)` (translucent blue)
- **Recent Block**: `rgba(247, 147, 26, 0.9)` (more opaque orange)
- **Selected Block**: `rgba(255, 255, 255, 0.95)` (highlighted white)
- **Distant Block**: `rgba(128, 128, 128, 0.6)` (faded gray)

#### Transaction Materials
- **High Fee**: `rgba(255, 68, 68, 0.8)` (red for expensive)
- **Medium Fee**: `rgba(247, 147, 26, 0.7)` (orange for moderate)
- **Low Fee**: `rgba(0, 200, 81, 0.6)` (green for cheap)
- **Pending**: `rgba(255, 255, 255, 0.5)` (white for unconfirmed)

#### UTXO Materials
- **Large UTXO**: `rgba(255, 215, 0, 0.9)` (gold for valuable)
- **Medium UTXO**: `rgba(192, 192, 192, 0.8)` (silver for moderate)
- **Small UTXO**: `rgba(205, 127, 50, 0.7)` (bronze for small)

## Typography

### Font Families

#### Primary Font: SF Pro Display
- **Usage**: Headers, titles, primary UI text
- **Weights**: Light (300), Regular (400), Medium (500), Semibold (600), Bold (700)
- **Characteristics**: Apple's system font, optimized for visionOS

#### Secondary Font: SF Mono
- **Usage**: Code, addresses, transaction IDs, technical data
- **Weights**: Regular (400), Medium (500), Semibold (600)
- **Characteristics**: Monospace font for technical precision

#### Accent Font: SF Pro Rounded
- **Usage**: Playful elements, onboarding, casual messaging
- **Weights**: Regular (400), Medium (500), Semibold (600)
- **Characteristics**: Friendly, approachable variant

### Type Scale

#### Spatial Text Sizes (3D Space)
- **Hero**: 0.12 units (large floating headers)
- **Title**: 0.08 units (section titles)
- **Subtitle**: 0.06 units (subsection headers)
- **Body**: 0.04 units (standard readable text)
- **Caption**: 0.03 units (small details, metadata)
- **Micro**: 0.02 units (tiny labels, technical data)

#### UI Text Sizes (2D Interface)
- **Display**: 34pt (major headings)
- **Title 1**: 28pt (page titles)
- **Title 2**: 22pt (section headers)
- **Title 3**: 20pt (subsection headers)
- **Headline**: 17pt (emphasized body text)
- **Body**: 17pt (standard body text)
- **Callout**: 16pt (secondary body text)
- **Subhead**: 15pt (tertiary text)
- **Footnote**: 13pt (small text)
- **Caption 1**: 12pt (captions)
- **Caption 2**: 11pt (smallest text)

### Line Heights
- **Tight**: 1.2 (headings, compact layouts)
- **Normal**: 1.4 (body text, readable content)
- **Relaxed**: 1.6 (long-form content, accessibility)

## Spacing System

### Base Unit: 8pt Grid
All spacing follows an 8-point grid system for consistency.

#### Spatial Spacing (3D Units)
- **XXS**: 0.01 units (2pt equivalent)
- **XS**: 0.02 units (4pt equivalent)
- **SM**: 0.04 units (8pt equivalent)
- **MD**: 0.08 units (16pt equivalent)
- **LG**: 0.16 units (32pt equivalent)
- **XL**: 0.32 units (64pt equivalent)
- **XXL**: 0.64 units (128pt equivalent)

#### UI Spacing (2D Points)
- **XXS**: 2pt (tight spacing)
- **XS**: 4pt (minimal spacing)
- **SM**: 8pt (small spacing)
- **MD**: 16pt (standard spacing)
- **LG**: 24pt (large spacing)
- **XL**: 32pt (extra large spacing)
- **XXL**: 48pt (maximum spacing)

### Component Spacing
- **Button Padding**: 12pt vertical, 16pt horizontal
- **Card Padding**: 16pt all sides
- **Modal Padding**: 24pt all sides
- **Section Spacing**: 32pt between major sections
- **Element Spacing**: 8pt between related elements

## Motion and Animation

### Timing Functions
- **Ease Out**: `cubic-bezier(0.25, 0.46, 0.45, 0.94)` (natural deceleration)
- **Ease In**: `cubic-bezier(0.55, 0.055, 0.675, 0.19)` (natural acceleration)
- **Ease In Out**: `cubic-bezier(0.645, 0.045, 0.355, 1)` (smooth transitions)
- **Spring**: Custom spring animation for spatial interactions

### Duration Scale
- **Instant**: 0ms (immediate feedback)
- **Fast**: 150ms (quick transitions)
- **Normal**: 300ms (standard transitions)
- **Slow**: 500ms (deliberate animations)
- **Slower**: 800ms (dramatic effects)

### 3D Animation Properties
- **Block Rotation**: 2-second rotation for selected blocks
- **Transaction Flow**: 1-second flow animation for tx visualization
- **Camera Movement**: 1.5-second smooth camera transitions
- **Fade In/Out**: 0.5-second opacity transitions
- **Scale Effects**: 0.3-second scale animations for interactions

## Shadows and Depth

### Shadow Levels
- **Level 1**: `0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24)`
- **Level 2**: `0 3px 6px rgba(0,0,0,0.16), 0 3px 6px rgba(0,0,0,0.23)`
- **Level 3**: `0 10px 20px rgba(0,0,0,0.19), 0 6px 6px rgba(0,0,0,0.23)`
- **Level 4**: `0 14px 28px rgba(0,0,0,0.25), 0 10px 10px rgba(0,0,0,0.22)`
- **Level 5**: `0 19px 38px rgba(0,0,0,0.30), 0 15px 12px rgba(0,0,0,0.22)`

### 3D Depth Cues
- **Near Objects**: Higher opacity, sharper edges, stronger shadows
- **Far Objects**: Lower opacity, softer edges, lighter shadows
- **Depth Fog**: Gradual opacity reduction with distance
- **Atmospheric Perspective**: Slight blue tint for distant objects

## Border Radius

### Radius Scale
- **None**: 0pt (sharp corners)
- **Small**: 4pt (subtle rounding)
- **Medium**: 8pt (standard rounding)
- **Large**: 12pt (pronounced rounding)
- **XLarge**: 16pt (very rounded)
- **Pill**: 999pt (fully rounded)

### Component Radii
- **Buttons**: 8pt (medium)
- **Cards**: 12pt (large)
- **Modals**: 16pt (xlarge)
- **Input Fields**: 6pt (small-medium)
- **Badges**: 999pt (pill)

## Iconography

### Icon Sizes
- **Small**: 16pt (inline icons)
- **Medium**: 24pt (standard icons)
- **Large**: 32pt (prominent icons)
- **XLarge**: 48pt (hero icons)

### Icon Style
- **Style**: SF Symbols (Apple's icon system)
- **Weight**: Regular (400) for most icons
- **Weight**: Medium (500) for emphasized icons
- **Weight**: Semibold (600) for critical actions

### 3D Icon Principles
- **Depth**: Icons have subtle 3D depth in spatial interface
- **Lighting**: Icons respond to environmental lighting
- **Scale**: Icons scale appropriately with distance
- **Interaction**: Icons provide haptic feedback on selection

## Accessibility

### Color Contrast
- **AA Compliance**: Minimum 4.5:1 contrast ratio for normal text
- **AAA Compliance**: Minimum 7:1 contrast ratio for enhanced accessibility
- **Large Text**: Minimum 3:1 contrast ratio for 18pt+ text

### Motion Preferences
- **Reduced Motion**: Respect system preference for reduced motion
- **Alternative Feedback**: Provide haptic feedback as motion alternative
- **Static Fallbacks**: Ensure functionality without animations

### Spatial Accessibility
- **Voice Control**: All elements accessible via voice commands
- **Gaze Tracking**: Support for eye-based navigation
- **Hand Tracking**: Gesture-based interaction support
- **Audio Cues**: Spatial audio feedback for interactions

## Platform-Specific Considerations

### visionOS Guidelines
- **Glass Materials**: Use system glass materials for UI elements
- **Depth Layering**: Respect visionOS depth hierarchy
- **Spatial Audio**: Integrate spatial audio feedback
- **Hand Tracking**: Design for natural hand gestures
- **Eye Tracking**: Support gaze-based interactions

### Performance Considerations
- **60 FPS Minimum**: Maintain smooth frame rates
- **LOD System**: Use level-of-detail for distant objects
- **Occlusion Culling**: Hide non-visible elements
- **Texture Optimization**: Use appropriate texture resolutions

---

**Version**: 1.0  
**Last Updated**: August 23, 2025  
**Status**: Initial design tokens defined  
**Next Review**: Gate 2 completion
