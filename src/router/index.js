import Vue from 'vue'
import VueRouter from 'vue-router'

import Home from '../views/Home.vue'
import Welcome from '../views/Welcome.vue'
import Modlists from '../views/Modlists.vue'
import Options from '../views/Options.vue'
import Dev from '../views/Dev.vue'
import Changelog from '../views/Changelog.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
    mode: 'hash',
    children: [
      {
        path: 'welcome',
        component: Welcome,
      },
      {
        path: '/',
        component: Modlists,
      },
      {
        path: 'options',
        component: Options,
      },
      {
        path: 'dev',
        component: Dev,
      },
      {
        path: 'changelog',
        component: Changelog,
      },
    ],
  },
]

const router = new VueRouter({
  routes,
})

export default router
