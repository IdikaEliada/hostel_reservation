// TemplateManager.ts
import { templates } from './index';

export interface Template {
  subject?: string;
  body: string;
}

/**
 * ✅ ADD push here
 */
export interface TemplateSet {
  email: Template;
  sms: Template;
  in_app: Template;
  push: Template; // ✅ NEW
}

/**
 * Get template set for a specific event
 */
export function getTemplate(event: string): TemplateSet {
  const template = templates[event];

  if (!template) {
    console.warn(`No template found for event: ${event}. Using default template.`);
    return {
      email: {
        subject: 'Notification',
        body: '<p>You have a new notification.</p>',
      },
      sms: {
        body: 'You have a new notification.',
      },
      in_app: {
        body: 'You have a new notification.',
      },
      push: {
        subject: 'Notification',
        body: 'You have a new notification.',
      },
    };
  }

  return template;
}

/**
 * Render template by replacing placeholders with actual data
 * Supports {{variable}} syntax
 */
export function renderTemplate(template: string, data: Record<string, any>): string {
  let rendered = template;

  Object.keys(data).forEach((key) => {
    const placeholder = new RegExp(`{{${key}}}`, 'g');
    rendered = rendered.replace(placeholder, String(data[key]));
  });

  // Remove any remaining unreplaced placeholders
  rendered = rendered.replace(/{{.*?}}/g, '');

  return rendered;
}
