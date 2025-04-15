###################################################
# Stage: base
###################################################
FROM node:20 AS base
WORKDIR /usr/local/app

################## CLIENT STAGES ##################

###################################################
# Stage: client-base
###################################################
FROM base AS client-base
COPY client/package.json client/yarn.lock ./client/
WORKDIR /usr/local/app/client
RUN --mount=type=cache,id=yarn,target=/usr/local/share/.cache/yarn \
    yarn install
# COPY client/.eslintrc.cjs client/index.html client/vite.config.js ./  use either this line or the one below* removed eslintrc.cjs as it was unavilable
COPY client/index.html client/vite.config.js ./ 
COPY client/public ./public
COPY client/src ./src

###################################################
# Stage: client-dev
###################################################
FROM client-base AS client-dev
CMD ["yarn", "dev"]

###################################################
# Stage: client-build
###################################################
FROM client-base AS client-build
RUN yarn build

################## BACKEND STAGES ##################

###################################################
# Stage: backend-dev
###################################################
FROM base AS backend-dev
COPY backend/package.json backend/yarn.lock ./backend/
WORKDIR /usr/local/app/backend
RUN --mount=type=cache,id=yarn,target=/usr/local/share/.cache/yarn \
    yarn install --frozen-lockfile
COPY backend/src ./src
CMD ["yarn", "dev"]

###################################################
# Stage: test
###################################################
FROM backend-dev AS test
RUN yarn test

###################################################
# Stage: final
###################################################
FROM base AS final
ENV NODE_ENV=production
WORKDIR /usr/local/app/backend
COPY --from=test /usr/local/app/backend/package.json /usr/local/app/backend/yarn.lock ./
RUN --mount=type=cache,id=yarn,target=/usr/local/share/.cache/yarn \
    yarn install --production --frozen-lockfile
COPY backend/src ./src
COPY --from=client-build /usr/local/app/client/dist ./src/static
EXPOSE 3000
CMD ["node", "src/index.js"]
