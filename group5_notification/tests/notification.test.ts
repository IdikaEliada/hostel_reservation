
import { NotificationService } from '../src/services/NotificationService';
import { NotificationRepository } from '../src/repositories/NotificationRepository';
import { EmailService, SmsService } from '../src/services/ChannelServices';

// Mocks
jest.mock('uuid', () => ({ v4: () => 'test-uuid' }));
jest.mock('../src/repositories/NotificationRepository');
jest.mock('../src/services/ChannelServices');
// We need to mock firebase config because it runs on import
jest.mock('../src/config/firebase', () => ({
    db: {
        collection: jest.fn(() => ({
            doc: jest.fn(() => ({
                get: jest.fn(() => Promise.resolve({
                    exists: true,
                    data: () => ({ email: 'test@example.com', phoneNumber: '1234567890' })
                }))
            }))
        }))
    }
}));

describe('NotificationService', () => {
    beforeEach(() => {
        jest.clearAllMocks();
    });

    it('should create 3 subscription records for a single event', async () => {
        const payload = { userId: 'user1', event: 'PASSWORD_RESET', payload: { name: 'Test', link: 'http', code: '123' } };

        await NotificationService.sendNotification(payload);

        // Expect repository create to be called 3 times (Email, SMS, InApp)
        expect(NotificationRepository.create).toHaveBeenCalledTimes(3);

        // Expect channel calls
        expect(EmailService.send).toHaveBeenCalled();
        expect(SmsService.send).toHaveBeenCalled();
    });
});
