import Vue from 'vue'
import VueRouter from 'vue-router'

import Home from '../views/Home.vue'
import Welcome from '../views/Welcome.vue'
import Modlists from '../views/Modlists.vue'
import Options from '../views/Options.vue'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
    mode: 'hash',
    children: [
      {
        path: '',
        component: Welcome
      },
      {
        path: 'modlists',
        component: Modlists
      },
      {
        path: 'options',
        component: Options
      }
    ]
  }
]

const router = new VueRouter({
  routes
})

export default router
