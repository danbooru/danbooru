#!/usr/bin/env bash

psql -c "UPDATE posts SET is_flagged = false, is_pending = true, approver_id = null WHERE id = 1" danbooru2
psql -c "DELETE FROM unapprovals" danbooru2
