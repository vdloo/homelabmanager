from django.test import TestCase
from django.urls import reverse


class TestAutomaticLoginMiddleware(TestCase):
    def setUp(self):
        self.admin_url = reverse('admin:index')

    def test_automatic_login_middleware_does_not_require_login_to_access_admin(self):
        ret = self.client.get(self.admin_url)

        # Would be 302 redirect to the login page without the middleware
        self.assertEqual(ret.status_code, 200)
