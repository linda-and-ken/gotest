#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-gotest:local}"
CONTAINER_NAME="${CONTAINER_NAME:-gotest-app}"
PORT="${PORT:-8080}"

# 若 daemon 仍指向失效的 registry.docker-cn.com，可改用公开 Hub 代理镜像（站点可能变更，以实际可拉取为准）：
#   HUB_MIRROR=docker.m.daocloud.io/library bash start.sh
HUB_MIRROR="${HUB_MIRROR:-}"

cd "$ROOT"

# 注意：在 set -u 下，空数组的 "${arr[@]}" 在部分 bash（如 macOS 自带 3.2）会报 unbound variable，故分支调用 docker build。
if [[ -n "$HUB_MIRROR" ]]; then
	docker build \
		--build-arg "BUILDER_IMAGE=${HUB_MIRROR}/golang:1.24-alpine" \
		--build-arg "RUNTIME_IMAGE=${HUB_MIRROR}/alpine:3.21" \
		-t "$IMAGE_NAME" .
else
	docker build -t "$IMAGE_NAME" .
fi

docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

docker run -d --name "$CONTAINER_NAME" -p "${PORT}:8080" "$IMAGE_NAME"

echo "容器已启动: $CONTAINER_NAME"
echo "访问: http://127.0.0.1:${PORT}/"
echo "查看日志: docker logs -f $CONTAINER_NAME"
echo "停止: docker stop $CONTAINER_NAME"
