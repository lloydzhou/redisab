class ABTest {
  constructor(option) {
    this.option = {
      base: '/ab',
      env: 'production',
      ...option,
    }
  }
  test(name, default_value) {
    const { base, env, user_id } = this.option
    return fetch(`${base}/var?name=${name}`, {
      mode: 'cors',
      credentials: 'include',
      headers: {
        'X-User-Id': user_id,
        'X-Env': env,
      }
    }).then(res => res.json()).then(data => {
      const { code, type, value } = data
      if (code === 0) {
        if (type === 'number') {
          return parseInt(value, 10)
        }
        return value
      }
      return default_value
    }).catch(e => {
      return default_value
    })
  }
  track(targets) {
    const { base, env, user_id } = this.option
    return fetch(`${base}/track`, {
      method: 'POST',
      mode: 'cors',
      credentials: 'include',
      headers: {
        'X-User-Id': user_id,
        'X-Env': env,
      },
      body: JSON.stringify(targets),
    })
  }
  traget(name, value) {
    return this.track({ [name]: value })
  }
}

export default ABTest
