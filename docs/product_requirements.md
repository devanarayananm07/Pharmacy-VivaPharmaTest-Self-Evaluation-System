# Product Requirements — PharmaQ

## Objective
Enhance pharmacist knowledge, provide adaptive assessment, enforce a 150-question weekly target, and deliver a smooth SPA-like mobile experience.

## Technical Stack
- **Frontend:** Flutter
- **Backend:** Python Flask (business logic, CSV/Excel parsing)
- **Data Flow:** REST APIs (fully dynamic)

## Smart Question Management
- **Non-repeating questions:** Tracked per employee and counter.
- **Duplicate Prevention:** Avoids duplicate Generic Name questions in Easy mode.
- **Tracking:** Automatic tracking of completed questions (resets only after full cycle).

## Weekly Target Logic
- **Requirement:** 150 questions per week per employee.
- **Compliance:** System tracks progress and ensures compliance.

## Difficulty Configuration
- Admin/Mentor configured based on days or completion of a full question set in a counter.

## Exam Modes
- **Easy:** Shows Generic Name. Answers: Brand, Strength/Dosage, Schedule, Indication, Company.
- **Medium:** Focuses on Indication, Company, Brand. Associative knowledge.
- **Hard:** Scenario-based/indirect clinical reasoning questions.