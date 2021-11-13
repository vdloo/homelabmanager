import django.test

from unittest.mock import patch, Mock


class TestCase(django.test.TestCase):
    def set_up_patch(self, patch_target, mock_target=None, **kwargs):
        patcher = patch(patch_target, mock_target or Mock(**kwargs))
        self.addCleanup(patcher.stop)
        return patcher.start()
