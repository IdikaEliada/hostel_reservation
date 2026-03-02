import axios from 'axios';

export const EmailService = {
  async send(to: string, htmlContent: string, subject: string): Promise<boolean> {
    const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;
    const FROM_EMAIL = process.env.FROM_EMAIL || 'noreply@yourdomain.com';

    if (!SENDGRID_API_KEY) {
      console.error('SENDGRID_API_KEY not configured');
      return false;
    }

    try {
      const response = await axios.post(
        'https://api.sendgrid.com/v3/mail/send',
        {
          personalizations: [
            {
              to: [{ email: to }],
              subject,
            },
          ],
          from: { email: FROM_EMAIL },
          content: [
            {
              type: 'text/html',
              value: htmlContent,
            },
          ],
        },
        {
          headers: {
            Authorization: `Bearer ${SENDGRID_API_KEY}`,
            'Content-Type': 'application/json',
          },
        }
      );

      // SendGrid returns 202 Accepted on success
      if (response.status === 202) return true;

      console.error('SendGrid unexpected status:', response.status, response.data);
      return false;
    } catch (error: any) {
      console.error(
        'SendGrid error:',
        error?.response?.status,
        error?.response?.data || error?.message
      );
      return false;
    }
  },
};

/**
 * SMS Service using Termii API
 */
export const SmsService = {
  async send(to: string, message: string): Promise<boolean> {
    const TERMII_API_KEY = process.env.TERMII_API_KEY;
    const TERMII_SENDER_ID = process.env.TERMII_SENDER_ID || 'YourApp';

    if (!TERMII_API_KEY) {
      console.error('TERMII_API_KEY not configured');
      return false;
    }

    try {
      const response = await axios.post(
        'https://api.ng.termii.com/api/sms/send',
        {
          to,
          from: TERMII_SENDER_ID,
          sms: message,
          type: 'plain',
          channel: 'dnd',
          api_key: TERMII_API_KEY,
        },
        { headers: { 'Content-Type': 'application/json' } }
      );

      // Termii success varies, but message_id existing is a good sign
      if (response.data?.message_id) return true;

      console.error('Termii unexpected response:', response.data);
      return false;
    } catch (error: any) {
      console.error(
        'Termii error:',
        error?.response?.status,
        error?.response?.data || error?.message
      );
      return false;
    }
  },
};