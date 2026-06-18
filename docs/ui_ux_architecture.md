# UI/UX Architecture — PharmaQ

## Clean Architecture
Strict separation of:
- **Domain:** Entities, Use Cases.
- **Data:** Models, Repositories, Remote Data Sources.
- **Presentation:** UI, State Management (BLoC/Provider).

## UX/UI Language: Medical Minimalism
- **Palette:** Obsidian (Dark Mode) with clinical accents (Teal/Blue).
- **Layout:** Structured Bento Grids for dashboards.
- **Effects:** Glassmorphism strictly for floating elements (action bars, badges).
- **Interactions:** Fast, responsive, zero page-reloads.

## Navigation
Four-tab modular system:
1. **Home (Exam):** Start Viva flow, filters, and dynamic exam window.
2. **Study Material:** Filterable prep materials (locked during viva).
3. **Score:** Bento grid dashboard with performance trends.
4. **Profile:** Account management and settings.