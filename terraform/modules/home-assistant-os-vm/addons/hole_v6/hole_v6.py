"""*hole API Python client."""
import asyncio
import logging
import socket

import aiohttp
import async_timeout

_LOGGER = logging.getLogger(__name__)
_INSTANCE = "{schema}://{host}/api"
_INSTANCE_WITH_LOCATION = "{schema}://{host}/{location}/api"
_MAX_WAIT = 10

class Hole(object):
    """A class for handling connections with a *hole instance."""

    def __init__(
        self,
        host,
        session,
        location=None,
        tls=False,
        verify_tls=True,
        api_token=None
    ):
        """Initialize the connection to a *hole instance."""
        self._session = session
        self.tls = tls
        self.verify_tls = verify_tls
        self.schema = "https" if self.tls else "http"
        self.host = host
        self.location = location
        self.api_token = api_token
        self.data = {}
        self.sid = None
        self.base_url = _INSTANCE_WITH_LOCATION.format(
            schema=self.schema, host=self.host, location=self.location
        )  if location else _INSTANCE.format(
            schema=self.schema, host=self.host
        )


    async def login(self):
        """Get details of a *hole instance."""
        try:
            async with async_timeout.timeout(5):
                response = await self._session.post(self.base_url + "/auth", json={'password': f'{self.api_token}'}, ssl=self.verify_tls)
            _LOGGER.debug("Response from *hole: %s", response.status)
            if (response.status != 200):
                msg = "Authentication failed for *hole: {} using {}".format(self.host, self.base_url)
                _LOGGER.error(msg)
                raise HoleConnectionError(msg)
            
            session_data = await response.json()
            _LOGGER.debug("Response from *hole: %s", session_data['session']['sid'])
            self.sid = session_data['session']['sid']
        except (asyncio.TimeoutError, aiohttp.ClientError, socket.gaierror):
            msg = "Can not login to *hole: {}".format(self.host)
            _LOGGER.error(msg)
            raise HoleConnectionError(msg)

        
    async def get_data(self):
        """Get details of a *hole instance."""
        try:
            if (not self.sid):
                await self.login()

            async with async_timeout.timeout(5):
                response = await self._session.get(self.base_url + "/padd", headers={'sid': self.sid}, ssl=self.verify_tls)

            _LOGGER.debug("Response from *hole: %s", response.status)
            self.data = await response.json()
            _LOGGER.debug(self.data)            

        except (asyncio.TimeoutError, aiohttp.ClientError, socket.gaierror):
            msg = "Can not load data from *hole: {}".format(self.host)
            _LOGGER.error(msg)
            raise HoleConnectionError(msg)


    async def enable(self):
        """Enable DNS blocking on a *hole instance."""
        try:
            if (not self.sid):
                await self.login()

            async with async_timeout.timeout(5):
                response = await self._session.post(self.base_url + "/dns/blocking", json={'blocking': True}, headers={'sid': self.sid}, ssl=self.verify_tls)
                _LOGGER.debug("Response from *hole: %s", response.status)

                wait_cycles = 0
                while self.status != "enabled" and wait_cycles < _MAX_WAIT:
                    _LOGGER.debug("Awaiting status to be enabled")
                    await self.get_data()
                    await asyncio.sleep(0.01)
                    wait_cycles += 1
                
                if (self.status != "enabled"):
                    msg = "Enabling DNS blocking failed for *hole: {} - Timeout waiting for status to change.".format(self.host)
                    _LOGGER.error(msg)
                    raise HoleConnectionError(msg)

            data = self.status
            _LOGGER.debug(data)

        except (asyncio.TimeoutError, aiohttp.ClientError, socket.gaierror):
            msg = "Can not load data from *hole: {}".format(self.host)
            _LOGGER.error(msg)
            raise HoleConnectionError(msg)


    async def disable(self, duration=None):
        """Disable DNS blocking on a *hole instance."""
        try:
            if (not self.sid):
                await self.login()

            async with async_timeout.timeout(5):
                response = await self._session.post(self.base_url + "/dns/blocking", json={'blocking': False, 'timer': duration}, headers={'sid': self.sid}, ssl=self.verify_tls)
                _LOGGER.debug("Response from *hole: %s", response.status)

                wait_cycles = 0
                while self.status != "disabled" and wait_cycles < _MAX_WAIT:
                    _LOGGER.debug("Awaiting status to be disabled")
                    await self.get_data()
                    await asyncio.sleep(0.01)
                    wait_cycles += 1

                if (self.status != "disabled"):
                    msg = "Disabling DNS blocking failed for *hole: {} - Timeout waiting for status to change.".format(self.host)
                    _LOGGER.error(msg)
                    raise HoleConnectionError(msg)

            data = self.status
            _LOGGER.debug(data)

        except (asyncio.TimeoutError, aiohttp.ClientError, socket.gaierror):
            msg = "Can not load data from *hole: {}".format(self.host)
            _LOGGER.error(msg)
            raise HoleConnectionError(msg)


    @property
    def status(self):
        """Return the status of the *hole instance."""
        return self.data["blocking"]

    @property
    def unique_clients(self):
        """Return the unique clients of the *hole instance."""
        return self.data["active_clients"]

    @property
    def unique_domains(self):
        """Return the unique domains of the *hole instance."""
        return "n/a"

    @property
    def ads_blocked_today(self):
        """Return the ads blocked today of the *hole instance."""
        return self.data["queries"]["blocked"]

    @property
    def ads_percentage_today(self):
        """Return the ads percentage today of the *hole instance."""
        return self.data["queries"]["percent_blocked"]

    @property
    def clients_ever_seen(self):
        """Return the clients_ever_seen of the *hole instance."""
        return "n/a"

    @property
    def dns_queries_today(self):
        """Return the dns queries today of the *hole instance."""
        return self.data["queries"]["total"]

    @property
    def domains_being_blocked(self):
        """Return the domains being blocked of the *hole instance."""
        return self.data["gravity_size"]

    @property
    def queries_cached(self):
        """Return the queries cached of the *hole instance."""
        return self.data["cache"]["inserted"]

    @property
    def queries_forwarded(self):
        """Return the queries forwarded of the *hole instance."""
        return "n/a"

    @property
    def ftl_current(self):
        """Return the current version of FTL of the *hole instance."""
        return self.data["version"]["ftl"]["local"]["version"]

    @property
    def ftl_latest(self):
        """Return the latest version of FTL of the *hole instance."""
        return self.data["version"]["ftl"]["remote"]["version"]

    @property
    def ftl_update(self):
        """Return wether an update of FTL of the *hole instance is available."""
        return self.data["version"]["ftl"]["local"]["version"] != self.data["version"]["ftl"]["remote"]["version"]

    @property
    def core_current(self):
        """Return the current version of the *hole instance."""
        return self.data["version"]["core"]["local"]["version"]

    @property
    def core_latest(self):
        """Return the latest version of the *hole instance."""
        return self.data["version"]["core"]["remote"]["version"]

    @property
    def core_update(self):
        """Return wether an update of the *hole instance is available."""
        return self.data["version"]["core"]["local"]["version"] != self.data["version"]["core"]["remote"]["version"]

    @property
    def web_current(self):
        """Return the current version of the web interface of the *hole instance."""
        return self.data["version"]["web"]["local"]["version"]

    @property
    def web_latest(self):
        """Return the latest version of the web interface of the *hole instance."""
        return self.data["version"]["web"]["remote"]["version"]

    @property
    def web_update(self):
        """Return wether an update of web interface of the *hole instance is available."""
        return self.data["version"]["web"]["local"]["version"] != self.data["version"]["web"]["remote"]["version"]
    
    @property
    def versions(self):
        return {
            "core_current": self.core_current,
            "core_latest": self.core_latest,
            "core_update": self.core_update,
            "web_current": self.web_current,
            "web_latest": self.web_latest,
            "web_update": self.web_update,
            "FTL_current": self.ftl_current,
            "FTL_latest": self.ftl_latest,
            "FTL_update": self.ftl_update
        }


class HoleError(Exception):
    """General HoleError exception occurred."""

    pass


class HoleConnectionError(HoleError):
    """When a connection error is encountered."""

    pass